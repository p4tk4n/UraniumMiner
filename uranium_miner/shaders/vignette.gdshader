shader_type canvas_item;

uniform float cutout_size = 100.0;
uniform float fade_width = 100.0;

void fragment() {
	// Get screen size from SCREEN_PIXEL_SIZE
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;

	// Get center of screen
	vec2 center = screen_size * 0.5;

	// Calculate distance from center in pixels
	vec2 pixel_pos = FRAGCOORD.xy - center;
	float distance_from_center = length(pixel_pos);

	float cutout_radius = cutout_size * 0.5;

	// Smooth fade from transparent to black
	float alpha = smoothstep(
		cutout_radius,
		cutout_radius + fade_width,
		distance_from_center
	);

	COLOR = vec4(0.11, 0.11,0.15, alpha);
}

void light() {}