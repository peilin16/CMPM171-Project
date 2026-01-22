shader_type canvas_item;

uniform float dissolve : hint_range(0.0, 1.0) = 0.0; // 0=正常, 1=完全消失
uniform float edge_width : hint_range(0.0, 0.2) = 0.06; // 边缘宽度
uniform vec4 edge_color : source_color = vec4(0.6, 0.9, 1.0, 1.0); // 边缘光颜色
uniform float noise_strength : hint_range(0.0, 1.0) = 0.25; // 溶解边缘抖动
uniform float noise_scale : hint_range(1.0, 50.0) = 18.0;

float hash(vec2 p){
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment(){
    vec4 tex = texture(TEXTURE, UV);
    if(tex.a <= 0.001){
        COLOR = vec4(0.0);
       
    }else{
		// UV中心到边缘的半径(0中心 -> ~0.707角落)
	    float r = distance(UV, vec2(0.5));

	    // 让 dissolve(0..1) 映射到 “空洞半径”
	    float hole = dissolve * 0.75; // 0.75左右差不多能吃掉整个sprite

	    // 噪声让边缘更像“溶解”
	    float n = noise(UV * noise_scale + TIME * 2.0);
	    float jitter = (n - 0.5) * noise_strength * 0.15;

	    // mask: 1=保留, 0=溶解
	    // r < hole => 逐渐变透明
	    float cut = smoothstep(hole + jitter, hole + edge_width + jitter, r);

	    // 边缘发光：在 cut 的过渡区间亮起来
	    float edge = 1.0 - smoothstep(hole + jitter, hole + edge_width + jitter, r);
	    edge *= smoothstep(hole - edge_width + jitter, hole + jitter, r);

	    vec3 col = tex.rgb;
	    col += edge_color.rgb * edge * 1.2;

	    float alpha = tex.a * cut;

	    COLOR = vec4(col, alpha);
		
	}

    
}