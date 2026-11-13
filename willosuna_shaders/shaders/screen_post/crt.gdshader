// Willosuna 2D Shaders: CRT monitor
// Curved CRT screen with scanlines, RGB phosphor mask, color bleed and dark
// corners. Put it on a ColorRect on top of the game.
// Use on: ColorRect over the screen (or any part of it).
// Godot 4.3 or newer. Every uniform below has a range hint and a comment.
// Free to use in your commercial games; see LICENSE.txt in the pack.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform float curvature : hint_range(0.0, 0.5, 0.005) = 0.12; // Barrel curvature of the glass.
uniform float scanline_strength : hint_range(0.0, 1.0, 0.01) = 0.35; // Darkness of the scanlines.
uniform float scanline_size : hint_range(1.0, 8.0, 1.0) = 3.0; // Screen pixels per scanline.
uniform float mask_strength : hint_range(0.0, 1.0, 0.01) = 0.25; // RGB phosphor mask.
uniform float bleed : hint_range(0.0, 4.0, 0.05) = 1.0; // Color bleed in screen pixels.
uniform float vignette : hint_range(0.0, 2.0, 0.01) = 0.6; // Dark corners.
uniform float brightness : hint_range(0.5, 2.0, 0.01) = 1.15; // Makes up for the darkening.
uniform float flicker : hint_range(0.0, 0.2, 0.005) = 0.02; // Subtle brightness flicker.

void fragment() {
	vec2 rect_px = 1.0 / max(abs(vec2(dFdx(UV.x), dFdy(UV.y))), vec2(1e-6));
	vec2 to_screen = rect_px * SCREEN_PIXEL_SIZE;
	vec2 c = UV * 2.0 - 1.0;
	vec2 uv = c * (1.0 + curvature * dot(c, c)) * 0.5 + 0.5;
	vec2 suv = SCREEN_UV + (uv - UV) * to_screen;
	vec2 b = vec2(bleed, 0.0) * SCREEN_PIXEL_SIZE;
	vec3 col;
	col.r = texture(screen_texture, suv + b).r;
	col.g = texture(screen_texture, suv).g;
	col.b = texture(screen_texture, suv - b).b;
	float line = mod(floor(uv.y * rect_px.y / scanline_size), 2.0);
	col *= 1.0 - scanline_strength * line;
	int m = int(mod(floor(uv.x * rect_px.x), 3.0));
	vec3 mask = m == 0 ? vec3(1.0, 0.7, 0.7) : (m == 1 ? vec3(0.7, 1.0, 0.7) : vec3(0.7, 0.7, 1.0));
	col *= mix(vec3(1.0), mask, mask_strength);
	vec2 v = uv * (1.0 - uv.yx);
	col *= pow(clamp(v.x * v.y * 15.0, 0.0, 1.0), vignette * 0.5);
	col *= brightness * (1.0 - flicker + flicker * sin(TIME * 110.0));
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		col = vec3(0.0);
	}
	COLOR = vec4(col, 1.0);
}
