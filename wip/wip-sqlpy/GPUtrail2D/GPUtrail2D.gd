@tool
@icon("bounce.svg")
class_name GPUTrail2D
extends GPUParticles2D

## A node for creating a ribbon trail effect in 2D.
## (Based on the 3D version by celyk; adapted to 2D)

# TODO:
# - Add flipbook support
# - Hide the actual GPUParticles2D node
# - Restructure code, use enums for flags
# - Add more polygons for a smoother trail
# - Add an acceleration parameter
# - Refine the 2D billboard/rotation behavior
# - Allow custom material

# PUBLIC

@export var length : int = 100: set = _set_length
@export var length_seconds : float = 0.0: set = _set_length

@export_category("Color / Texture")

@export var scroll : Vector2 = Vector2.ZERO: set = _set_scroll
@export var color_ramp : GradientTexture1D: set = _set_color_ramp
@export var curve : CurveTexture: set = _set_curve
@export var vertical_texture : bool = false: set = _set_vertical_texture
@export var use_red_as_alpha : bool = false: set = _set_use_red_as_alpha

@export_category("Mesh tweaks")

@export var billboard : bool = false: set = _set_billboard
@export var dewiggle : bool = true: set = _set_dewiggle
@export var clip_overlaps : bool = true: set = _set_clip_overlaps
@export var snap_to_transform : bool = false: set = _set_snap_to_transform

# PRIVATE

const _DEFAULT_TEXTURE = "res://wip/wip-sqlpy/GPUtrail2D/defaults/texture.tres"
const _DEFAULT_CURVE = "res://wip/wip-sqlpy/GPUtrail2D/defaults/curve.tres"

var _defaults_have_been_set = false
func _get_property_list():
	return [{"name": "_defaults_have_been_set", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_NO_EDITOR}]

# In 2D, we use Vector2 and Transform2D.
@onready var _old_pos : Vector2 = global_position
@onready var _billboard_transform : Transform2D = global_transform

# These materials manage particle processing and drawing.
var draw_pass_1 : ShaderMaterial

var _uv_offset : Vector2 = Vector2.ZERO
var _flags : int = 0

func _ready():
	if not _defaults_have_been_set:
		_defaults_have_been_set = true
		amount = length
		lifetime = length
		explosiveness = 1  # emits all particles at once

		fixed_fps = int(DisplayServer.screen_get_refresh_rate(DisplayServer.MAIN_WINDOW_ID))
		if fixed_fps <= 0:
			push_warning("Could not get refresh rate. Using fixed_fps = 60")
			fixed_fps = 60

		# Set up the process material (using a 2D-adapted shader)
		process_material = ShaderMaterial.new()
		process_material.shader = preload("res://wip/wip-sqlpy/GPUtrail2D/shaders/trail2d.gdshader")
		material = process_material  # assign to the GPUParticles2D node

		# Set up the draw pass material for the trail (2D version)
		draw_pass_1 = ShaderMaterial.new()
		draw_pass_1.shader = preload("res://wip/wip-sqlpy/GPUtrail2D/shaders/trail_draw_pass_2d.gdshader")
		draw_pass_1.resource_local_to_scene = true

		# Load default textures if not provided
		if not color_ramp:
			color_ramp = preload(_DEFAULT_TEXTURE).duplicate(true)
		if not curve:
			curve = preload(_DEFAULT_CURVE).duplicate(true)
	
	_set_length(length)
	_set_vertical_texture(vertical_texture)
	_set_use_red_as_alpha(use_red_as_alpha)
	_set_billboard(billboard)
	_set_dewiggle(dewiggle)
	_set_clip_overlaps(clip_overlaps)
	_set_snap_to_transform(snap_to_transform)

func _set_length(value):
	# This function acts as the setter for length and length_seconds.
	if typeof(value) == TYPE_INT:
		length = max(value, 1)
		length_seconds = float(length) / fixed_fps
	elif typeof(value) == TYPE_FLOAT:
		length = max(int(value * fixed_fps), 1)
		length_seconds = float(length) / fixed_fps
	
	if _defaults_have_been_set:
		amount = length
		lifetime = length
	
	restart()
	return

func _set_texture(value):
	texture = value
	_uv_offset = Vector2.ZERO  # Reset UV scroll
	if value:
		draw_pass_1.set_shader_parameter("tex", texture)
	else:
		draw_pass_1.set_shader_parameter("tex", preload(_DEFAULT_TEXTURE))
	return

func _set_scroll(value):
	scroll = value
	return

func _set_color_ramp(value):
	color_ramp = value
	draw_pass_1.set_shader_parameter("color_ramp", color_ramp)
	return

func _set_curve(value):
	curve = value
	if value:
		draw_pass_1.set_shader_parameter("curve", curve)
	else:
		draw_pass_1.set_shader_parameter("curve", preload(_DEFAULT_CURVE))
	return

func _set_vertical_texture(value):
	vertical_texture = value
	_flags = _set_flag(_flags, 0, value)
	draw_pass_1.set_shader_parameter("flags", _flags)
	return

func _set_use_red_as_alpha(value):
	use_red_as_alpha = value
	_flags = _set_flag(_flags, 1, value)
	draw_pass_1.set_shader_parameter("flags", _flags)
	return

func _set_billboard(value):
	billboard = value
	_flags = _set_flag(_flags, 2, value)
	draw_pass_1.set_shader_parameter("flags", _flags)
	if value and _defaults_have_been_set:
		_update_billboard_transform((global_position - _old_pos).normalized())
	restart()
	return

func _set_dewiggle(value):
	dewiggle = value
	_flags = _set_flag(_flags, 3, value)
	draw_pass_1.set_shader_parameter("flags", _flags)
	return

func _set_snap_to_transform(value):
	snap_to_transform = value
	_flags = _set_flag(_flags, 4, value)
	draw_pass_1.set_shader_parameter("flags", _flags)
	return

func _set_clip_overlaps(value):
	clip_overlaps = value
	_flags = _set_flag(_flags, 5, value)
	draw_pass_1.set_shader_parameter("flags", _flags)
	return

func _set_flag(i, idx: int, value: bool) -> int:
	return (i & ~(1 << idx)) | (int(value) << idx)

func _process(delta):
	# If snapping to the node transform, update the emission transform in the shader.
	if snap_to_transform:
		draw_pass_1.set_shader_parameter("emission_transform", global_transform)
	
	# Update UV scrolling.
	_uv_offset += scroll * delta
	_uv_offset.x = fposmod(_uv_offset.x, 1.0)
	_uv_offset.y = fposmod(_uv_offset.y, 1.0)
	draw_pass_1.set_shader_parameter("uv_offset", _uv_offset)
	
	# Billboard behavior: rotate the node toward its movement.
	if billboard:
		var delta_position = global_position - _old_pos
		if delta_position != Vector2.ZERO:
			var tangent = delta_position.normalized()
			_update_billboard_transform(tangent)
		global_transform = _billboard_transform
	
	_old_pos = global_position

func _update_billboard_transform(tangent: Vector2):
	# In 2D the “billboard” is simply a rotation adjustment.
	_billboard_transform = global_transform
	var current_angle = _billboard_transform.get_rotation()
	var target_angle = tangent.angle()
	var angle_diff = target_angle - current_angle
	_billboard_transform = _billboard_transform.rotated(angle_diff)
	_billboard_transform = _billboard_transform.scaled(Vector2(0.5, 0.5))
	_billboard_transform.origin += _billboard_transform.y
