
class_name PostProcessFilter
extends CanvasLayer # post_processing.gd
# Based on theshaggydev's open source project https://github.com/theshaggydev/unto-deepest-depths-shader
# Use Case: Allowing other nodes to access the front-most screen's shader parameters.
@export var shader_rect: ShaderRect
@export var force_front: bool = false
@export var max_layer: int = 25
func _ready()->void:
	# Set the shader Rect to full screen
	shader_rect.set_anchors_preset(shader_rect.PRESET_FULL_RECT)
	# If we'd like the PostProcessFilter to be infront of everything
	# This will put it at a reasonibly high layer.
	if force_front:
		layer = max_layer


func get_shader_param(param:String)->float:
	return shader_rect.material.get_shader_parameter(param)

func set_shader_param_float(param:String, value:float)->void:
	shader_rect.material.set_shader_parameter(param, value)

func set_shader_param_int(param:String, value:int)->void:
	shader_rect.material.set_shader_parameter(param, value)

func set_shader_param_string(param:String, value:String)->void:
	shader_rect.material.set_shader_parameter(param, value)

func set_shader_param_bool(param:String, value:bool)->void:
	shader_rect.material.set_shader_parameter(param, value)

func set_shader_param(param:String, value)->void: # Use only if the Shader's parameter isn't a common type
	shader_rect.material.set_shader_parameter(param, value)
