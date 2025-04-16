extends Node
class_name DealDamageOnCollsion

@export var min_speed_for_damage: float = 5.0  # Linear Velocity
@export var damage: int = 1
var parent : RigidBody2D
var has_dealt_damage: bool = false
func _ready() -> void:
	parent = get_parent()
	parent.contact_monitor = true
	if parent.max_contacts_reported < 5:
		parent.max_contacts_reported = 5

func _physics_process(delta: float) -> void:
	# Check collisions
	if parent.linear_velocity.length() > min_speed_for_damage:
		if parent.get_contact_count() > 0:
			for body in parent.get_colliding_bodies():
				if has_dealt_damage: return
				if body.has_method("take_damage"):
					body.take_damage(damage)
					has_dealt_damage = true
