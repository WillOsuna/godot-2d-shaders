// Willosuna 2D Shaders: Rain
// Three depth layers of slanted rain with pixel-width streaks, adjustable
// angle, density and speed, plus an overcast darkening.
// Use on: ColorRect (any size) over the scene.
// Godot 4.3 or newer. Every uniform below has a range hint and a comment.
// Free to use in your commercial games; see LICENSE.txt in the pack.
shader_type canvas_item;

uniform vec4 rain_color : source_color = vec4(0.75, 0.85, 1.0, 0.65); // Drop color and opacity.
uniform float density : hint_range(0.0, 1.0, 0.01) = 0.5; // Fraction of columns with rain.
uniform float speed : hint_range(0.1, 5.0, 0.05) = 1.6; // Rect heights per second (near layer).
uniform float angle : hint_range(-45.0, 45.0, 0.5) = 12.0; // Slant in degrees.
uniform float drop_length : hint_range(0.01, 0.3, 0.005) = 0.07; // Streak length (fraction of the rect height).
uniform float drop_width : hint_range(1.0, 6.0, 1.0) = 1.0; // Streak width in screen pixels.
uniform float column_spacing : hint_range(2.0, 40.0, 1.0) = 9.0; // Screen pixels between columns.
uniform int layers : hint_range(1, 3) = 3; // Depth layers.
uniform float overcast : hint_range(0.0, 1.0, 0.01) = 0.15; // Darkens the scene.

float h(float x) {
	return fract(sin(x * 91.345) * 47453.5453);
}

void fragment() {
	vec2 rect_px = 1.0 / max(abs(vec2(dFdx(UV.x), dFdy(UV.y))), vec2(1e-6));
	vec2 px = floor(UV * rect_px);
	float s = tan(radians(angle));
	float a = 0.0;
	for (int l = 0; l < 3; l++) {
		if (l >= layers) {
			break;
		}
		float depth = 1.0 - float(l) * 0.3;
		float spacing = column_spacing * (0.55 + 0.45 * depth);
		vec2 q = vec2(px.x - px.y * s + float(l) * 37.0, px.y);
		float col = floor(q.x / spacing);
		float hc = h(col + float(l) * 17.3);
		if (hc > density) {
			continue;
		}
		float xin = q.x - col * spacing;
		if (xin >= max(1.0, floor(drop_width * depth + 0.5))) {
			continue;
		}
		float period = drop_length * (2.5 + 4.0 * h(col * 1.7 + 3.0));
		float v = speed * (0.45 + 0.55 * depth) * (0.85 + hc * 0.3);
		float pos = fract((UV.y - TIME * v) / period + hc * 7.0);
		float r = drop_length * (0.6 + 0.4 * depth) / period;
		if (pos < r) {
			a = max(a, pos / r * (0.35 + 0.65 * depth));
		}
	}
	float ra = a * rain_color.a;
	float alpha = 1.0 - (1.0 - overcast) * (1.0 - ra);
	vec3 c = (rain_color.rgb * ra + vec3(0.02, 0.03, 0.06) * overcast * (1.0 - ra)) / max(alpha, 1e-4);
	COLOR = vec4(c, alpha);
}
