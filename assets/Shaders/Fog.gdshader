shader_type canvas_item;

uniform float density : hint_range(0.0, 1.0) = 0.5;
uniform vec4 fog_color : source_color = vec4(0.8, 0.85, 0.9, 1.0);
uniform float speed : hint_range(0.0, 1.0) = 0.08;
uniform vec2 scale = vec2(3.0, 3.0);

float rand(vec2 c) {
	return fract(sin(dot(c, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 c) {
	vec2 i = floor(c);
	vec2 f = fract(c);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(rand(i), rand(i + vec2(1, 0)), u.x),
	           mix(rand(i + vec2(0, 1)), rand(i + vec2(1, 1)), u.x), u.y);
}

float fbm(vec2 c) {
	float v = 0.0, a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += noise(c) * a;
		c *= 2.0;
		a *= 0.5;
	}
	return v;
}

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
	vec2 uv = SCREEN_UV * scale + vec2(TIME * speed, TIME * speed * 0.4);
	float fog = smoothstep(0.15, 0.75, fbm(uv));
	vec4 bg = texture(screen_texture, SCREEN_UV);
	COLOR = mix(bg, fog_color, fog * density);
}
