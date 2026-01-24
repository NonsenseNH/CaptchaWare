shader_type canvas_item;

uniform float scroll_speed = 0.0;
uniform float set_speed = 0.03;

void vertex() {
	UV.y += (TIME * set_speed) + scroll_speed;
}