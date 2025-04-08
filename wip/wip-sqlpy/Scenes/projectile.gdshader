shader_type canvas_item;

uniform float scroll = -1.0;
uniform sampler2D scroll_tex : hint_default_white;
uniform sampler2D static_tex_1 : hint_default_white;
uniform sampler2D static_tex_2 : hint_default_white;

void fragment() {
	COLOR = texture(scroll_tex, vec2(mod(UV.x + TIME * scroll, 1.0), UV.y)) * texture(static_tex_1, UV) * texture(static_tex_2, UV) * COLOR;
}