shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.1) = 0.0;
uniform float softness : hint_range(0.01, 1.0) = 0.1;
uniform vec2 texture_size = vec2(512.0, 512.0); // actual texture size in pixels

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 aspect = vec2(texture_size.x / texture_size.y, 1.0);

    // Remap UV to maintain circular shape across different aspect ratios
    vec2 adjusted_uv = (UV - center) * aspect;
    float dist = length(adjusted_uv);

    // Radius of the inner transparent area shrinks with progress
    float radius = mix(2.0, 0.0, progress);

    float edge0 = radius - softness * 0.5;
    float edge1 = radius + softness * 0.5;

    float alpha = smoothstep(edge0, edge1, dist);

    // At progress=0, full transparency; at progress=1, fully black
    COLOR = vec4(0.0, 0.0, 0.0, mix(0.0, alpha, 1.0));
}
