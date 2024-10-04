shader_type canvas_item;

uniform float time_factor = 0.2;
uniform vec2 amplitude = vec2(20.0,5.0);

void vertex() {
	// cos giving float between -1, 1
	VERTEX.x += step(cos(TIME * time_factor + VERTEX.x + VERTEX.y) + 1.0, 1.0) * amplitude.x;
	VERTEX.y += step(cos(TIME * time_factor + VERTEX.x + VERTEX.y) + 1.0, 1.0) * amplitude.y;
}