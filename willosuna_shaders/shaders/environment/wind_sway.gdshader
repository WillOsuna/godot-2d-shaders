// Willosuna 2D Shaders: Wind sway (grass, trees, plants)
// Bends plants and trees in the wind with a gust on top, base anchored.
// Pixel snap moves whole pixels per row so pixel art stays crisp. Neighbours
// desync by world position.
// Use on: Sprite2D, AnimatedSprite2D, TextureRect.
// Godot 4.3 or newer. Every uniform below has a range hint and a comment.
// Free to use in your commercial games; see LICENSE.txt in the pack.
shader_type canvas_item;

uniform float strength : hint_range(0.0, 16.0, 0.1) = 3.0; // Max sway at the top, texture pixels.
uniform float speed : hint_range(0.0, 6.0, 0.05) = 1.5; // Sway speed.
uniform float stiffness : hint_range(0.5, 4.0, 0.05) = 1.6; // Higher = only the top moves.
uniform float gust_strength : hint_range(0.0, 1.0, 0.01) = 0.35; // Extra slow gust wave.
uniform float phase_offset : hint_range(0.0, 6.283, 0.01) = 0.0; // Desync copies (also varies with world x).
uniform bool pixel_snap = true; // Shifts whole texture pixels per row (crisp pixel art).
uniform bool anchor_bottom = true; // On: the bottom row never moves.

varying vec4 vcolor; // Vertex color and modulate (in fragment, COLOR already includes the texture).

varying float world_phase;

vec4 tex_at(sampler2D tex, vec2 uv) {
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return vec4(0.0);
	}
	return texture(tex, uv);
}

void vertex() {
	vcolor = COLOR;
	vec2 g = vec2((UV.x * 2.0 - 1.0) * ceil(strength), 0.0);
	VERTEX += g;
	world_phase = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).x * 0.013;
}

void fragment() {
	vec2 uvg = vec2(UV.x + (UV.x * 2.0 - 1.0) * ceil(strength) * TEXTURE_PIXEL_SIZE.x, UV.y);
	float y = pixel_snap ? (floor(uvg.y / TEXTURE_PIXEL_SIZE.y) + 0.5) * TEXTURE_PIXEL_SIZE.y : uvg.y;
	float h = anchor_bottom ? clamp(1.0 - y, 0.0, 1.0) : 1.0;
	float w = pow(h, stiffness);
	float t = TIME * speed + phase_offset + world_phase;
	float off = (sin(t) + gust_strength * 2.0 * sin(t * 0.37 + 1.3)) / (1.0 + gust_strength) * strength * w;
	if (pixel_snap) {
		off = round(off);
	}
	COLOR = tex_at(TEXTURE, uvg - vec2(off * TEXTURE_PIXEL_SIZE.x, 0.0)) * vcolor;
}
