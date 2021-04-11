shader_type canvas_item;

uniform sampler2D emission;
uniform vec4 glow1: hint_color;
uniform vec4 glow2: hint_color;
uniform vec4 glow3: hint_color;
uniform vec4 glow4: hint_color;
uniform float strength = 2.2;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	vec4 emission_color = texture(emission, UV);
	if (emission_color.r <= 1f && emission_color.r > 0.8) {
		COLOR = current_color + glow1 * strength;
	} 
	else if (emission_color.r <= 0.8 && emission_color.r > 0.6) {
		COLOR = current_color + glow2 * strength;
	}
	else if (emission_color.r <= 0.6 && emission_color.r > 0.4) {
		COLOR = current_color + glow3 * strength;
	}
	else if (emission_color.r > 0f && emission_color.r <= 0.4) {
		COLOR = current_color //+ glow4 * strength;
	}
	else {
		COLOR = current_color
	}
}