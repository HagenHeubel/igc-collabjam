shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D tex;
uniform vec2 uv_offset = vec2(0.0);
uniform sampler2D color_ramp;
uniform sampler2D curve;
uniform mat3 emission_transform = mat3(1.0);
uniform int flags = 0;

// Bitmask flags.
#define VERTICAL_TEXTURE   bool(flags & 1)
#define USE_RED_AS_ALPHA   bool(flags & 2)
#define DEWIGGLE           bool(flags & 4)
#define CLIP_OVERLAPS      bool(flags & 8)

varying vec2 v_uv; // Pass original UV to fragment.

void vertex() {
    // Store incoming UV
    v_uv = UV;

    // If your particle system already calculates correct screen/local coordinates,
    // you might not need to multiply by the MODEL_MATRIX:
    vec2 center = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy - MODEL_MATRIX[3].xy;


    // Apply the particle’s rotation (in radians from INSTANCE_CUSTOM.x)
    float angle = INSTANCE_CUSTOM.x;
    vec2 dir = vec2(cos(angle), sin(angle));
    // Perpendicular to the particle direction
    vec2 perp = vec2(-dir.y, dir.x);

    // Normalize the progress along the trail if you’re passing it in custom data.
    // (Optional: if your particle process shader passes the current index and total count via custom channels,
    //  uncomment and adjust the following lines to re-map UV.x)
    float index = INSTANCE_CUSTOM.w;
    float count = INSTANCE_CUSTOM.z;
    UV.x = (UV.x + index - 1.0 - 2.0) / (count - 1.0);

    // Use INSTANCE_CUSTOM.y as normalized progress along the trail to drive thickness.
    float progress = INSTANCE_CUSTOM.y;
    float thickness = texture(curve, vec2(progress, 0.0)).r;

    // Define half–width (adjust scale factor 10.0 as needed)
    float half_width = thickness * 10.0;

    // Compute the top and bottom edge positions based on the perpendicular direction.
    vec2 top = center + perp * half_width;
    vec2 bottom = center - perp * half_width;

    // Interpolate between the two edges: UV.x = 0 gives top edge, UV.x = 1 gives bottom.
    vec2 pos = mix(top, bottom, UV.x);

    // Optionally apply dewiggle (if enabled, be sure it’s intentional).
    if (DEWIGGLE) {
        pos *= thickness;
        UV *= thickness;
    }

    // Output the final vertex position
    VERTEX = pos;
}
