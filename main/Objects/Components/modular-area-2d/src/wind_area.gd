extends Area2D
class_name WindArea

@export_range(-1,1, 2) var wind_direction: int = 1
@export var wind_strength: float = 300.0
@export var affects_particles: bool = false
@export var printing: bool = true
@export var auto_setup: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	gravity_direction = Vector2(wind_direction, 0)
	gravity = wind_strength
	
	if auto_setup:
		monitorable = false
		gravity_space_override = Area2D.SPACE_OVERRIDE_COMBINE
		priority = -1 ## Allows other more obtrusive areas to alter gravity first
		set_collision_layer_value(1, false)
		set_collision_mask_value(3, true)
		set_collision_mask_value(5, true)
	
	if affects_particles:
		set_collision_mask_value(6, true)

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is CharacterBody2D:
		if printing: print("Wind Areas not implemented for CharacterBody2D")
