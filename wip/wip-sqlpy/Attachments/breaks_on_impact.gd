class_name BreaksOnImpact
extends Node

@export_range(0.0, 4000.0, 1.0) var force_required : int = 200.0
@export var subtract_gravity : bool = true
@export var ignore_player_collisions : bool = true
@export var output_debug_collision_force : bool = false


signal break_triggered(Vector2)
var parent : RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	parent.contact_monitor = true
	if parent.max_contacts_reported < 5:
		parent.max_contacts_reported = 5

func _process(delta: float) -> void:
	var colliding_bodies = parent.get_colliding_bodies()
	if not colliding_bodies.is_empty():
		var parent_RID : RID = parent.get_rid()
		var state : PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(parent_RID)
		var collision_force = Vector2.ZERO
		for i in range(state.get_contact_count()):
			if ignore_player_collisions:
				if state.get_contact_collider(i) == GlobalVars.player.get_rid():
					return
			collision_force += state.get_contact_impulse(i)
		if subtract_gravity:
			collision_force += ProjectSettings.get_setting("physics/2d/default_gravity") * parent.mass * parent.gravity_scale * Vector2.UP * 0.02
		if collision_force.length() > force_required:
			break_triggered.emit(collision_force)
