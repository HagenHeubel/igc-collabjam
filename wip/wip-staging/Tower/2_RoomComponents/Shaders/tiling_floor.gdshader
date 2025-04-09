shader_type canvas_item;

uniform sampler2D tex;

void fragment() {
	vec2 texture_size = vec2(textureSize(tex, 0));
	COLOR = texture(tex, mod(UV / (texture_size / texture_size.y), 1.0));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
