shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	uv.x = (uv.x - 0.5) * 2.0;
	uv.x = sqrt(1.0 - uv.x * U);
	uv.y = UV.y;
	COLOR = texture(TEXTURE, uv);
}