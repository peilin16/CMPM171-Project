shader_type canvas_item;
render_mode unshaded;

// 0 = off, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia
uniform float mode : hint_range(0.0, 3.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear, repeat_disable;

void fragment() {
	vec4 tex = texture(screen_texture, SCREEN_UV);

	if (mode < 0.5) {
		COLOR = tex;
	} else {
		vec3 rgb = tex.rgb;
		vec3 sim;
		vec3 correction;

		// Simulate perception first, then shift lost information into visible channels.
		if (mode < 1.5) {
			// Protanopia
			sim = vec3(
				0.152286 * rgb.r + 1.052583 * rgb.g - 0.204868 * rgb.b,
				0.114503 * rgb.r + 0.786281 * rgb.g + 0.099216 * rgb.b,
				-0.003882 * rgb.r - 0.048116 * rgb.g + 1.051998 * rgb.b
			);
			vec3 err = rgb - sim;
			correction = vec3(0.0, 1.0 * err.r, 1.0 * err.r);
		} else if (mode < 2.5) {
			// Deuteranopia
			sim = vec3(
				0.367322 * rgb.r + 0.860646 * rgb.g - 0.227968 * rgb.b,
				0.280085 * rgb.r + 0.672501 * rgb.g + 0.047413 * rgb.b,
				-0.011820 * rgb.r + 0.042940 * rgb.g + 0.968881 * rgb.b
			);
			vec3 err = rgb - sim;
			correction = vec3(0.0, 1.0 * err.r, 1.0 * err.r);
		} else {
			// Tritanopia
			sim = vec3(
				1.255528 * rgb.r - 0.076749 * rgb.g - 0.178779 * rgb.b,
				-0.078411 * rgb.r + 0.930809 * rgb.g + 0.147602 * rgb.b,
				0.004733 * rgb.r + 0.691367 * rgb.g + 0.303900 * rgb.b
			);
			vec3 err = rgb - sim;
			correction = vec3(1.0 * err.b, 1.0 * err.b, 0.0);
		}

		COLOR = vec4(clamp(rgb + correction, vec3(0.0), vec3(1.0)), tex.a);
	}
}
