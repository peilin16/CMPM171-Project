shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 debris_color : source_color = vec4(0.35, 0.75, 1.0, 1.0);

uniform float density = 12.0;        // 每条激光长度方向的“簇”数量（越大越多）
uniform float spawn_rate = 1.3;      // 每个簇刷新的速度（越大越快）
uniform float spread = 0.55;         // 向上下扩散的最大范围（UV y 方向）
uniform float drift_speed = 0.35;    // 扩散速度
uniform float dot_size = 0.05;       // 圆点大小（UV）
uniform float dot_soft = 0.02;       // 圆点边缘柔和
uniform float strength = 1.6;        // 碎屑强度

// 简单 hash
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float circle(vec2 p, vec2 c, float r, float soft) {
    float d = length(p - c);
    return 1.0 - smoothstep(r, r + soft, d);
}

void fragment() {
    vec2 uv = UV;

    // 如果你的 DebrisSprite 是纯白贴图，这里 alpha 就是 1
    float base_a = texture(TEXTURE, uv).a;

    // 沿 x 分成 density 个格子，每格生成 1~2 个点（固定循环，性能可控）
    float xcell = floor(uv.x * density);
    float xfrac = fract(uv.x * density);

    float t = TIME * spawn_rate;

    float acc = 0.0;

    // 生成两粒（你也可以改成 3 粒，但别太多）
    for (int i = 0; i < 2; i++) {
        float seed = xcell * 13.1 + float(i) * 101.7;

        // 每个 seed 有自己的相位
        float phase = hash11(seed + 1.23);
        float life = fract(t + phase);          // 0->1 循环
        float fade = smoothstep(1.0, 0.7, life) * smoothstep(0.0, 0.1, life); // 出现/消失

        // 从中心向上下扩散（随机决定上/下）
        float up = step(0.5, hash11(seed + 9.99)) * 2.0 - 1.0; // +1 or -1
        float yoff = up * (life * drift_speed) * spread;

        // x 方向在格子内随机摆放
        float xoff = (hash11(seed + 5.55) - 0.5) * 0.8;

        vec2 c = vec2( (xcell + 0.5 + xoff) / density, 0.5 + yoff );

        // 圆点大小也随机一点
        float r = dot_size * mix(0.2, 1.4, hash11(seed + 2.22));

        acc += circle(uv, c, r, dot_soft) * fade;
    }

    COLOR = debris_color * (acc * strength) * base_a;
}
