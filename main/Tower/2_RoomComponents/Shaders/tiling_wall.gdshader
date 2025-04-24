shader_type canvas_item;

uniform sampler2D tex;

void fragment() {
	vec2 texture_size = vec2(textureSize(tex, 0));
	vec2 uv = UV / (texture_size / texture_size.y);
	COLOR = texture(tex, mod(vec2(uv.x, uv.y), 1.0));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
