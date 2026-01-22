shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 beam_color : source_color = vec4(0.35, 0.75, 1.0, 1.0);

uniform float core_width = 0.18;      // 核心亮带宽度（0~0.5，越小越“细芯”）
uniform float edge_soft = 0.05;       // 边缘过渡柔和度
uniform float glow_strength = 2.2;    // 总发光强度
uniform float outer_glow = 0.9;       // 外发光（比核心更宽）

uniform float wave_amp = 0.00;       // 波动幅度（UV）
uniform float wave_freq = 18.0;       // 波动频率（沿长度）
uniform float wave_speed = 6.0;       // 波动速度

void fragment() {
    vec2 uv = UV;

    // 让波动主要作用在中间，边缘少动（看起来更像能量流）
    float center_mask = 1.0 - smoothstep(0.0, 0.5, abs(uv.y - 0.5));
    float wobble = sin(uv.x * wave_freq + TIME * wave_speed) * wave_amp * center_mask;
    uv.y += wobble;

    // 取原始贴图 alpha（你原来的激光贴图）
    vec4 tex = texture(TEXTURE, uv);
    float a = tex.a;

    // 沿厚度方向：中心亮、上下暗（注意：这是“上下”渐变，不是左右）
    float d = abs(uv.y - 0.5); // 0 在中间，0.5 在边缘
    float core = 1.0 - smoothstep(core_width, core_width + edge_soft, d);
    float outer = 1.0 - smoothstep(core_width + outer_glow, core_width + outer_glow + edge_soft, d);

    // 核心更亮，外圈更柔
    float intensity = core * glow_strength + outer * (glow_strength * 0.55);

    // 把贴图本身也作为“能量纹理”参与（让中间不会完全平）
    float tex_boost = mix(0.65, 1.25, tex.r); // 用贴图红通道当细节也行
    intensity *= tex_boost;

    COLOR = beam_color * intensity * a;
}