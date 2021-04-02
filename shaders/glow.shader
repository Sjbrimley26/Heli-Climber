shader_type canvas_item;

uniform sampler2D emission;
uniform vec4 glow: hint_color;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	vec4 emission_color = texture(emission, UV);
	if (emission_color.a > 0f) {
		COLOR = current_color + glow * emission_color.a * 2.2
	} else {
		COLOR = current_color
	}
}