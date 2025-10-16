shader_type canvas_item;

uniform sampler2D base_texture;

uniform vec2 base_texture_offset = vec2(0.5, 0.5);
uniform vec2 base_texture_scale = vec2(413.0, 403.0);

void fragment() {
    vec4 mask_color = texture(TEXTURE, UV);
	vec2 base_texture_real_scale = base_texture_scale / vec2(100,100);

    vec2 base_uv = (UV - (base_texture_offset / vec2(100, 100))) / base_texture_real_scale;
    vec4 base_color;

    if (base_uv.x >= 0.0 && base_uv.x <= 1.0 &&
        base_uv.y >= 0.0 && base_uv.y <= 1.0) {
        base_color = texture(base_texture, base_uv);
    } else {
        base_color = vec4(0.0, 0.0, 0.0, 0.0);
    }
    float final_alpha = base_color.a * mask_color.a;
    COLOR = vec4(base_color.rgb, final_alpha);
}