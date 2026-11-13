// Willosuna 2D Shaders: Hit flash
// Flashes the sprite to a solid color when it takes damage. Animate
// flash_amount from 1 to 0 with a Tween.
// Use on: Sprite2D, AnimatedSprite2D, TextureRect.
// Godot 4.3 or newer. Every uniform below has a range hint and a comment.
// Free to use in your commercial games; see LICENSE.txt in the pack.
shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Flash color.
uniform float flash_amount : hint_range(0.0, 1.0, 0.01) = 0.0; // 0 = normal, 1 = solid color. Tween it 1 -> 0 on hit.
uniform bool keep_shading = false; // On: keeps a hint of the sprite's shading during the flash.

varying vec4 vcolor; // Vertex color and modulate (in fragment, COLOR already includes the texture).

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

void vertex() {
	vcolor = COLOR;
}

void fragment() {
	vec4 base = texture(TEXTURE, UV) * vcolor;
	vec3 target = flash_color.rgb;
	if (keep_shading) {
		target = flash_color.rgb * (0.7 + 0.5 * luma(base.rgb));
	}
	COLOR = vec4(mix(base.rgb, target, flash_amount * flash_color.a), base.a);
}
