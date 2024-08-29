shader_type spatial;
render_mode cull_disabled;

uniform vec3 base_color : source_color;
uniform vec3 highlight_color : source_color;
uniform float transparency = 0.5;
uniform float amount = 4.0;
uniform float intensity = 4.5;

void vertex() {
	
}

vec3 fresnel_glow(float _amount, float _intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), _amount) * color * _intensity;
}
void fragment() {
	//ALBEDO = vec3(0.0,0.0,0.0);
	//EMISSION = emission_color;
	ALPHA = transparency;
	vec3 fresnel = fresnel_glow(amount, intensity, highlight_color, NORMAL, VIEW);
	ALBEDO = base_color + fresnel;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
