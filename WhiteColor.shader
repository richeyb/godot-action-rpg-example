shader_type canvas_item;

uniform bool active = true;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	if (active) {
		vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
		COLOR = white_color;
	} else {
		COLOR = previous_color;
	}
}