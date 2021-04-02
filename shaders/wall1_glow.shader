shader_type canvas_item;

uniform sampler2D emission;
uniform vec4 glow1: hint_color;
uniform vec4 glow2: hint_color;
uniform vec4 glow3: hint_color;
uniform float strength = 2.2;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	vec4 emission_color = texture(emission, UV);
	if (emission_color.r < 1f && emission_color.r > 0.7) {
		COLOR = current_color + glow1 * emission_color.a * strength;
	} 
	else if (emission_color.r < 0.7 && emission_color.r > 0.5) {
		COLOR = current_color + glow2 * emission_color.a * strength;
	}
	else if (emission_color.r > 0f) {
		COLOR = current_color + glow3 * emission_color.a * strength;
	}
	else {
		COLOR = current_color
	}
}