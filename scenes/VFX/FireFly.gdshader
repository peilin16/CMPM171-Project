shader_type canvas_item;


uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.7, 1.0);  // 萤火虫的暖黄色
uniform float glow_intensity : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = tex_color * glow_color * glow_intensity;
    
    // 确保alpha正确
    COLOR.a = tex_color.a;
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
