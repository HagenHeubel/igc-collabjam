shader_type particles;
render_mode keep_data, disable_force, disable_velocity;

void process() {
	// Here CUSTOM.w tracks the particle’s position in the trail (1..LIFETIME)
	float amount = LIFETIME;
	
	vec4 a = EMISSION_TRANSFORM * vec4(0.0, 1.0, 1.0, 1.0);
	vec4 b = EMISSION_TRANSFORM * vec4(0.0, -1.0, 1.0, 1.0);
	
	// Initialize on first run.
	if (CUSTOM.w == 0.0) {
		CUSTOM.w = float(INDEX) + 1.0;
		// Pass total particle count to the draw pass.
		CUSTOM.z = amount;
		// Cache a default “quad” defined by the two edges.
		TRANSFORM = mat4(b, b, a, a);
	}
	
	// Wrap the trail index.
	if (CUSTOM.w == amount + 1.0) {
		CUSTOM.w = 1.0;
	}
	
	// On the first particle in the trail, reset the quad.
	if (CUSTOM.w == 1.0) {
		TRANSFORM = mat4(b, b, b, b);
	}
	
	// For the second particle, update the right edge.
	if (CUSTOM.w == 2.0) {
		TRANSFORM[1] = b;
		TRANSFORM[2] = a;
	}
	
	CUSTOM.w++;
}
