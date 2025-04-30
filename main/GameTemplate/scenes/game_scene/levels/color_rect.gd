extends ColorRect

func _process(delta: float) -> void:
	size = get_viewport_rect().size * 3.0
	position = GlobalVars.player.global_position - size / 2.0
	(material as ShaderMaterial).set_shader_parameter("progress", GlobalVars.screen_hole_progress)
	(material as ShaderMaterial).set_shader_parameter("texture_size", size)
