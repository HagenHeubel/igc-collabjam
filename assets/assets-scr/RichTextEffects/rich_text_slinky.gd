@tool
class_name RichTextSlinky extends RichTextEffect


var bbcode = "slinky"
@export var speed: float = 1.0
func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var sp = char_fx.env.get("speed", speed)
	char_fx.offset.x += pow(char_fx.relative_index * (sin(char_fx.elapsed_time * sp)), 2)
	return true
