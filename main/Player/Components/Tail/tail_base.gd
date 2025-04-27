@tool
extends Node2D
class_name CatTail

# Cannot be below the player in hierarchy (Must not be a child of the moving object)

@onready var static_body_2d: StaticBody2D = $StaticBody2D

## Must be a sibling of the PhysicsBody2D it follows
@export var attached_to_node : PouncePlayer2D
@export var follow_mouse : bool = false
## Assumes that the physicsbody it is attached to has a vector2 named velocity
@export var change_rotation_with_velocity : bool = true
@export_range(0.1,100.0,0.1) var position_lerp_exp : float = 20.0
@export_range(-360, 360, 0.5) var tail_rotation : float = 0.0
@export_enum("Left", "Right") var player_facing : String = "Right"
var start_position : Vector2
var relative_target_position : Vector2
var last_facing_direction : Vector2 = Vector2.RIGHT
var default_rotation : float
var final_rotation : float
var START_FACING : Vector2

func _ready() -> void:
	match player_facing:
		"Left":
			START_FACING = Vector2.LEFT
		"Right":
			START_FACING = Vector2.RIGHT
	last_facing_direction = START_FACING
	default_rotation = tail_rotation
	
	if not Engine.is_editor_hint():
		$EditorHint.queue_free()
	if attached_to_node:
		start_position = global_position - attached_to_node.global_position
		print(start_position)
		relative_target_position = start_position

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$EditorHint.rotation = deg_to_rad(tail_rotation)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if follow_mouse:
		static_body_2d.global_position = get_global_mouse_position()
	elif attached_to_node:
		_set_last_facing_direction()
		_set_relative_position(delta)
		_set_rotation(delta)

func _set_last_facing_direction() -> void:
	last_facing_direction = sign(attached_to_node.visual_component.scale.x) * START_FACING

func _set_relative_position(delta : float) -> void:
	
	# TODO: SET start_position DYNAMICALLY VIA ANIMATION. (reference position)
	
	#relative_target_position.x = Util.delta_lerp_vec2(relative_target_position, start_position * last_facing_direction, position_lerp_exp, delta).x
	relative_target_position = Util.delta_lerp_vec2(relative_target_position, start_position, position_lerp_exp, delta)
	
	static_body_2d.global_position = attached_to_node.global_position + relative_target_position

func _set_rotation(delta : float) -> void:
	if change_rotation_with_velocity:
		final_rotation = Util.delta_lerp(final_rotation,
			tail_rotation * sign(last_facing_direction.x) + 
			remap(attached_to_node.linear_velocity.x, -400, 400, -45, 45),
			10.0,
			delta * abs(attached_to_node.linear_velocity.x) * 0.005 + 0.001)
	static_body_2d.rotation = attached_to_node.rotation + deg_to_rad(final_rotation + 
		sin(Util.get_time_sec() * Math.E) * 3.0 + 
		sin(Util.get_time_sec() * Math.GoldenRatio) * 2.0 + 
		sin(Util.get_time_sec() * Math.PlasticConstant))
