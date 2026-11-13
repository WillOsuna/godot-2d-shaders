// Willosuna 2D Shaders: Dissolve with burning edge
// Noise dissolve with a two-color glowing edge. Pixel-perfect mode dissolves
// whole texture pixels. Animate progress 0 to 1.
// Use on: Sprite2D, AnimatedSprite2D, TextureRect, UI.
// Godot 4.3 or newer. Every uniform below has a range hint and a comment.
// Free to use in your commercial games; see LICENSE.txt in the pack.
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.0; // 0 = whole sprite, 1 = fully gone.
uniform vec4 edge_color : source_color = vec4(1.0, 0.45, 0.1, 1.0); // Outer edge color.
uniform vec4 edge_color_inner : source_color = vec4(1.0, 0.95, 0.55, 1.0); // Hot color right at the cut.
uniform float edge_width : hint_range(0.0, 0.3, 0.005) = 0.08; // Width of the glowing edge.
uniform float noise_scale : hint_range(1.0, 64.0, 0.5) = 10.0; // Higher = smaller dissolve blobs.
uniform bool pixel_perfect = true; // Dissolves whole texture pixels (crisp pixel art).
uniform float seed : hint_range(0.0, 100.0, 0.1) = 0.0; // Changes the pattern.

varying vec4 vcolor; // Vertex color and modulate (in fragment, COLOR already includes the texture).

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + vec2(17.1, 9.2);
		a *= 0.5;
	}
	return v;
}

void vertex() {
	vcolor = COLOR;
}

void fragment() {
	vec2 uv = pixel_perfect ? (floor(UV / TEXTURE_PIXEL_SIZE) + 0.5) * TEXTURE_PIXEL_SIZE : UV;
	vec4 base = texture(TEXTURE, UV) * vcolor;
	float n = clamp((fbm(uv * noise_scale + seed * 7.13) - 0.15) / 0.7, 0.0, 1.0);
	float cut = n - (progress * (1.0 + edge_width) - edge_width);
	vec3 c = base.rgb;
	float a = base.a;
	if (cut < 0.0) {
		a = 0.0;
	} else if (cut < edge_width) {
		float t = cut / max(edge_width, 0.0001);
		c = mix(edge_color_inner.rgb, edge_color.rgb, t);
		a = base.a * mix(edge_color_inner.a, edge_color.a, t);
	}
	COLOR = vec4(c, a);
}
