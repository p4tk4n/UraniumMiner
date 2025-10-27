shader_type canvas_item;

uniform float whiteness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 orig_color = texture(TEXTURE,UV);
	vec3 whitened = mix(orig_color.rgb,vec3(1.0),whiteness);
	COLOR = vec4(whitened * (1.0 + whiteness), orig_color.a);
}

