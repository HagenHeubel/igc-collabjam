shader_type canvas_item;
render_mode blend_sub;

uniform bool flip = false;
uniform sampler2D tex : source_color, hint_default_black;
void fragment() {
	COLOR = texture(tex, UV);
	if (flip) {
		COLOR -= clamp(UV.y - 0.6, 0.0, 1.0);
		COLOR -= clamp(0.2 - UV.y, 0.0, 1.0);
	} else {
		COLOR -= clamp(UV.y - 0.8, 0.0, 1.0);
		COLOR -= clamp(0.4 - UV.y, 0.0, 1.0);
	}
}
