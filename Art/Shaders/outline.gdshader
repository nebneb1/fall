shader_type spatial;
render_mode unshaded, blend_mix;
uniform sampler2D depth_texture : hint_depth_texture;
uniform vec3 outline_color : source_color = vec3(0.0, 0.0, 0.0);

float linear_depth_projection(float depth_raw, vec2 screen_uv, mat4 inv_proj){
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth_raw);
	vec4 view = inv_proj * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

float linear_depth(float depth_raw, float near, float far){
	return 1.0 / ((1.0 - far / near) * depth_raw + 1.0 / near);
}

void vertex() {
	VERTEX += NORMAL * 0.003;
}

void fragment() {
	float near = linear_depth_projection(0.0, SCREEN_UV, INV_PROJECTION_MATRIX);
	float far = linear_depth_projection(1.0, SCREEN_UV, INV_PROJECTION_MATRIX);
	
	float depth_raw = texture(depth_texture, SCREEN_UV).x;
	float depth_linear = linear_depth(depth_raw, near, far);
	
	vec2 pixel_size = (1.0 / depth_linear) / vec2(textureSize(depth_texture, 0));
	
	float neighbor1 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(-1, 1),  0).r, near, far);
	float neighbor2 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(0, 1),   0).r, near, far);
	float neighbor3 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(1, 1),   0).r, near, far);
	float neighbor4 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(-1, 0),  0).r, near, far);
	float neighbor5 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(1, 0),   0).r, near, far);
	float neighbor6 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(-1, -1), 0).r, near, far);
	float neighbor7 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(0, -1),  0).r, near, far);
	float neighbor8 = linear_depth(textureLod(depth_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * vec2(-1, 1),  0).r, near, far);
	
	float max_dst = 0.075;
	
	float edge1 = step(max_dst, abs(neighbor1 - depth_linear));
	float edge2 = step(max_dst, abs(neighbor2 - depth_linear));
	float edge3 = step(max_dst, abs(neighbor3 - depth_linear));
	float edge4 = step(max_dst, abs(neighbor4 - depth_linear));
	float edge5 = step(max_dst, abs(neighbor5 - depth_linear));
	float edge6 = step(max_dst, abs(neighbor6 - depth_linear));
	float edge7 = step(max_dst, abs(neighbor7 - depth_linear));
	float edge8 = step(max_dst, abs(neighbor8 - depth_linear));
	
	float all_edges = edge1 + edge2 + edge3 + edge4 + edge5 + edge6 + edge7 + edge8;
	float edges = step(0.5, all_edges);
	
	ALBEDO = outline_color;
	ALPHA = edges;
}