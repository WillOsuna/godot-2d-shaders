# Willosuna 2D Shaders for Godot 4 (free sample)

Six 2D shaders for Godot, each with a small demo scene, plus a gallery scene to see them all at once. Made for Godot 4.3 and newer.

| Shader | What it does |
|---|---|
| Outline (outer) | Pixel-perfect outline around a sprite, 1 to 8 px |
| Hit flash | Flashes the sprite to a solid color when it takes damage |
| Dissolve | Dissolves a sprite with a two-color glowing edge |
| Wind sway | Bends plants and trees in the wind, keeping pixel art crisp |
| Rain overlay | Three layers of slanted rain with adjustable angle, density and speed |
| CRT | Curved screen with scanlines, phosphor mask and dark corners |

## How to use

1. Copy the `willosuna_shaders` folder into your project (or install it from the Asset Library).
2. Open `willosuna_shaders/gallery/gallery.tscn` to see every shader in action.
3. To use one, add a `ShaderMaterial` to your Sprite2D, AnimatedSprite2D or TextureRect and pick the `.gdshader` file. The demo scenes show the settings I usually start with.

## Want more?

This is the free part of my [Godot 2D Shaders](https://willosuna.itch.io/godot-2d-shaders) pack, which has 70 shaders: screen effects, combat and status, color, environment and weather, outlines, UI transitions and magic.

The full pack, along with everything else I make (64 asset packs with pixel art, UI kits, sound effects and music), is in the [Willosuna All-in-One](https://willosuna.itch.io/willosuna-all-in-one). Every future pack is included.

## License

MIT, so you can use these in personal and commercial games. If you make something with them, I'd love to see it.
