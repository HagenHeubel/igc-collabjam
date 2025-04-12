class_name JumpPadArea2D
extends Area2D

@onready var original_modulate = modulate
@export var cooldown: float = 0.25 # in seconds
@export var enable_character_bodies: bool = true
@export var cb_force: float = 100.0 # velocity applied to character bodies
@export var enable_rigid_bodies: bool = true
@export var rb_force: float = 4200.0 # force applied to rigid bodies

@export var auto_setup: bool = true
@export var printing: bool = true
@export var debug: bool = true
var is_triggered: bool = false

func _ready() -> void:
	if auto_setup:
		monitorable = false
		# Project Specific Layering
		set_collision_layer_value(1, false)
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)
		set_collision_mask_value(5, true)
		
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if debug:
		if is_triggered:
			modulate = Color.RED
		else:
			modulate = original_modulate
		


func _on_body_entered(body: PhysicsBody2D) -> void:
	print("Body Entered Jumpad")
	if body == get_parent():
		if printing: print("Ignoring Parent Node")
		return
	if is_triggered == true:
		if printing: print("Jumpad cannot be used")
		return
	
	print("Cooldown started")
	if body is CharacterBody2D and enable_character_bodies:
		is_triggered = true
		body.velocity.y -= cb_force
		if printing: print("Applying Force to CharacterBody")
	if body is RigidBody2D and enable_rigid_bodies:
		var vertical_impulse := Vector2(0, -rb_force * body.mass)
		body.apply_central_impulse(vertical_impulse)
		is_triggered = true # set here to ensure impulse is applied evenly
		if printing: prints("Applying Impulse to Rigid", vertical_impulse)
	
	await get_tree().create_timer(cooldown).timeout
	is_triggered = false
	if printing: print("Cooldown ended")
