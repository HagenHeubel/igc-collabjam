@tool
class_name RichTextPivot extends RichTextEffect


var bbcode = "pivot"
@export var pivot_index: int = 0
@export var default_vertical: float = 6.0
@export var speed: int = 2
func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var vertical_size = char_fx.env.get("vertical_size", default_vertical)
	var pivot_index = char_fx.env.get("index", pivot_index)

	char_fx.offset.y += (vertical_size *
			abs(pivot_index - char_fx.relative_index)) *\
			( sin(char_fx.elapsed_time * speed) + 1) / 2
	return true
