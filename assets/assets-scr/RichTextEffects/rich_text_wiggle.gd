@tool
class_name RichTextWiggle extends RichTextEffect # resource

var bbcode := "wiggle"

@export  var rotation_angle: float = 0.1
@export var rotation_speed: float = 1.0
@export var text_rotate_offset: float = 0.1

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var angle = sin((char_fx.elapsed_time * rotation_speed) + float(text_rotate_offset * char_fx.relative_index)) * rotation_angle;
	char_fx.transform = char_fx.transform.rotated_local(angle)

	return true
