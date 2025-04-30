shader_type canvas_item;
render_mode blend_add;

uniform sampler2D noise1 : source_color;
uniform sampler2D noise2 : source_color;
uniform sampler2D noise3 : source_color;

// Rotation angle in radians
uniform float rotation;

// Speed multipliers for each texture scroll
uniform float speed1 = 0.1;
uniform float speed2 = 0.1;
uniform float speed3 = 0.2;
uniform float speed4 = 0.2;

vec2 rotate(vec2 v, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec2(
		c * v.x - s * v.y,
		s * v.x + c * v.y
	);
}

void fragment() {
	// Define scrolling direction (unit vector), to be rotated
	vec2 dir = vec2(1.0, 0.0);

	// Apply rotation
	vec2 rotated_dir = rotate(dir, rotation);

	// Scroll each texture in opposite directions with different speeds
	vec4 n1 = texture(noise1, mod(UV + rotated_dir * TIME * speed1, 1.0));
	vec4 n2 = texture(noise2, mod(UV - rotated_dir * TIME * speed2, 1.0));
	vec4 n3 = texture(noise3, mod(UV + rotated_dir * TIME * speed3, 1.0));
	vec4 n4 = texture(noise1, mod(UV - rotated_dir * TIME * speed4, 1.0));

	COLOR = vec4(n1.r, n2.g, n3.b, n4.r * n2.g);
}
