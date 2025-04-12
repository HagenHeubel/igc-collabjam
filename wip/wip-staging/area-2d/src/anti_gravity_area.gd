extends Area2D
class_name AntiGravityArea2D

@export var printing: bool = true
@export var auto_setup: bool = true
@export var affects_particles: bool = false


func _ready() -> void:
	if auto_setup:
		monitorable = false
		gravity_space_override = Area2D.SPACE_OVERRIDE_COMBINE
		gravity_direction = Vector2(0, -1.0)
		gravity = 100.0 #px
		angular_damp_space_override = Area2D.SPACE_OVERRIDE_COMBINE
		angular_damp = 50.0
		body_entered.connect(_on_body_entered)
		#body_exited.connect(_on_body_exited)
	if affects_particles:
		set_collision_mask_value(6, true)



func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is not RigidBody2D:
		if printing: print("Non-Rigid Body entered LowGravityArea2D")
		if body is CharacterBody2D:
			if printing: print("This is where I would put CharacterBody2D handling")
		return
	#
	#
#
#func _on_body_exited(body: PhysicsBody2D) -> void:
	#if body is not RigidBody2D:
		#if printing: print("Non-Rigid Body entered LowGravityArea2D")
		#return
	
	
