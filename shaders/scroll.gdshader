shader_type canvas_item;

uniform float scroll_speed = 0.01;

void vertex() {
	UV.y += (TIME * 0.05) + scroll_speed;
}