@tool
extends Node2D

# Cannot be below the player in hierarchy (Must not be a child of the moving object)

@onready var static_body_2d: StaticBody2D = $StaticBody2D

## Must be a sibling of the PhysicsBody2D it follows
@export var attached_to_node : PhysicsBody2D
@export var follow_mouse : bool = false
## Assumes that the physicsbody it is attached to has a vector2 named velocity
@export var change_rotation_with_velocity : bool = true
@export_range(-360, 360, 0.5) var tail_rotation : float = 0.0
var final_rotation : float

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if follow_mouse:
		static_body_2d.global_position = lerp(static_body_2d.global_position, get_global_mouse_position(), delta)
	if attached_to_node:
		if change_rotation_with_velocity:
			final_rotation = tail_rotation + Util.delta_lerp(final_rotation - tail_rotation, deg_to_rad(remap(attached_to_node.velocity.x, -400, 400, -45, 45)), 4.0, delta)
		static_body_2d.global_position = attached_to_node.global_position
		static_body_2d.rotation = attached_to_node.rotation + final_rotation

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$EditorHint.rotation = tail_rotation

func _ready() -> void:
	if not Engine.is_editor_hint():
		$EditorHint.queue_free()
