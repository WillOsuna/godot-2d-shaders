// Willosuna 2D Shaders: Outline (outer)
// Pixel-perfect outline around the opaque pixels, 1 to 8 px, 4-direction
// (pixel art) or rounded 8-direction. Grows the quad so the line is never
// cut.
// Use on: Sprite2D, AnimatedSprite2D, TextureRect.
// Godot 4.3 or newer. Every uniform below has a range hint and a comment.
// Free to use in your commercial games; see LICENSE.txt in the pack.
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Outline color (alpha respected).
uniform int width : hint_range(0, 8) = 1; // Thickness in texture pixels.
uniform bool round_corners = false; // Off: 4-direction pixel-art line. On: rounder 8-direction line.
uniform bool grow_quad = true; // Grows the quad so the outline is never cut. Turn off for atlas regions and pad the frames instead.

varying vec4 vcolor; // Vertex color and modulate (in fragment, COLOR already includes the texture).

float alpha_at(sampler2D tex, vec2 uv) {
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return 0.0;
	}
	return texture(tex, uv).a;
}

vec4 tex_at(sampler2D tex, vec2 uv) {
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return vec4(0.0);
	}
	return texture(tex, uv);
}

void vertex() {
	vcolor = COLOR;
	if (grow_quad) {
		vec2 g = (UV * 2.0 - 1.0) * float(width);
		VERTEX += g;
	}
}

void fragment() {
	vec2 uvg = grow_quad ? UV + (UV * 2.0 - 1.0) * float(width) * TEXTURE_PIXEL_SIZE : UV;
	vec4 base = tex_at(TEXTURE, uvg) * vcolor;
	float o = 0.0;
	float lim = round_corners ? (float(width) + 0.5) * (float(width) + 0.5) : float(width);
	for (int y = -width; y <= width; y++) {
		for (int x = -width; x <= width; x++) {
			float d = round_corners ? float(x * x + y * y) : float(abs(x) + abs(y));
			if (d <= lim && (x != 0 || y != 0)) {
				o = max(o, alpha_at(TEXTURE, uvg + vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE));
			}
		}
	}
	float oa = outline_color.a * o * vcolor.a;
	COLOR = vec4(mix(outline_color.rgb, base.rgb, base.a), base.a + oa * (1.0 - base.a));
}
