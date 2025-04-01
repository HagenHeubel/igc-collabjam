@tool
class_name RichTextColorPattern extends RichTextEffect
# [color_pattern colors=red,green]Example[/color_pattern]
# [color_pattern colors=red]Example[/color_pattern]
# [color_pattern colors=red,green,blue,yellow,purple,cyan]Example[/color_pattern]
var bbcode = "color_pattern"
@export var speed: float = 1.0

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var colors = char_fx.env.get("colors", ["red"])
	var color_pos = (char_fx.range.x +
			int(char_fx.elapsed_time * speed)) % len(colors)
	char_fx.color = colors[color_pos]
	return true
