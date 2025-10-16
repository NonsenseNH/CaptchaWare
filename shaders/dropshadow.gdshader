shader_type canvas_item;

uniform vec4 drop_shadow_color : source_color = vec4(vec3(0), float(0.5));
uniform vec2 shadow_offset = vec2(float(0), float(0.1));
uniform vec2 offset = vec2(float(0),float(0));

void vertex() {
	float max_offset = abs(shadow_offset.x);
	if (abs(shadow_offset.y) > abs(shadow_offset.x)) {
		max_offset = abs(shadow_offset.y);
	}
	VERTEX = (VERTEX * (float(1) + float(2) * max_offset));
}
vec4 sample_texture(sampler2D texture, vec2 uv)  {
	if ((uv.x < 0.0 || uv.x > 1.0) || (uv.y < 0.0 || uv.y > 1.0))  {
		return vec4(0.0);
	} else {
		return texture(texture, uv);
	}
}
vec4 mixcolor(vec4 colA, vec4 colB)  {
	return vec4((colA.rgb + colB.a * (colB.rgb - colA.rgb)), colA.a + colB.a);
}
void fragment()  {
	float max_offset = abs(shadow_offset.x);
	if (abs(shadow_offset.y) > abs(shadow_offset.x)) {
		max_offset = abs(shadow_offset.y);
	}
	vec2 uv = UV * float(float(1) + float(2) * max_offset) - vec2(max_offset);
	vec4 original_color = sample_texture(TEXTURE, uv);
	vec4 shadow_color = vec4(drop_shadow_color.rgb, sample_texture(TEXTURE, uv - shadow_offset).a * drop_shadow_color.a);
	if (shadow_color.a > float(0)) {
		COLOR = mixcolor(shadow_color, original_color);
	} else {
		COLOR = original_color;
	}
}