
class_name ShaderRect
extends ColorRect # shader_rect.gd

# Establishes a Class of Color Rects meant to specifically hold Shaders

func _ready() -> void:
	assert(material is ShaderMaterial, "ShaderRect does not contain ShaderMaterial")

func set_new_shader(new: Shader) -> void: material.set_shader(new)

func get_current_shader() -> Shader:	return material.get_shader()
