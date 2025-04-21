shader_type canvas_item;

uniform sampler2D tex : source_color;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	COLOR.a *= clamp(smoothstep(0.0, 1.0, 1.0 - length(uv)), 0.0, 1.0) * texture(tex, UV).r;
}
