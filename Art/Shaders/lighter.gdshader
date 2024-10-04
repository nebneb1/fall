shader_type canvas_item;

uniform float ammount = 10.0;

void fragment() {
	COLOR = COLOR * ammount;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
