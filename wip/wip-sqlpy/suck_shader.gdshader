shader_type canvas_item;

uniform sampler2D noise : source_color;
uniform sampler2D noise2 : source_color;
uniform sampler2D gradient : source_color;
uniform float speed : hint_range(0.0, 3.0, 0.01);

void fragment() {
    // Compute position relative to screen center (assumed 0.5, 0.5)
    vec2 center = vec2(0.5);
    vec2 pos = UV - center;
    
    // Convert cartesian position to polar coordinates
    float r = length(pos);
    float angle = atan(pos.y, pos.x);
    
    // Speed at which the noise scrolls inward; adjust as needed.
    // Subtract a time offset from the radial coordinate.
    // Using fract() makes it repeat seamlessly.
    float scrolled_r = mod(r - TIME * speed, 4.0);
    float scrolled_r_2 = mod(r - TIME * .7 * speed, 4.0);
    
    // Normalize angle from [-pi, pi] to [0, 1] for texture coordinates.
    float normalized_angle = (angle + PI) / TAU;
    
    // Construct UVs for the noise texture using the scrolled radial coordinate and normalized angle.
    vec2 noise_uv = vec2(scrolled_r * 0.25, normalized_angle);
    vec2 noise_uv_2 = vec2(scrolled_r_2 * .25, normalized_angle);
    vec4 noise_sample = texture(noise, noise_uv);
    vec4 noise_sample_2 = texture(noise2, noise_uv_2);
    
    // Sample the gradient texture normally.
    vec4 gradient_sample = texture(gradient, UV);
    COLOR *= gradient_sample;
	COLOR.a *= noise_sample.r * noise_sample_2.r;
}
