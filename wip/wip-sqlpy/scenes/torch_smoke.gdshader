shader_type canvas_item;

uniform sampler2D noise : source_color, hint_default_white;

void fragment() {
	COLOR = COLOR * texture(TEXTURE, UV) * texture(noise, UV).r;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
