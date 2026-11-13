extends Node
## Demo helper: animates one shader parameter on the parent's ShaderMaterial.
## Add it as a child of any Sprite2D / ColorRect / Control that has a
## ShaderMaterial. Not needed in your game; the shaders work without it.

## Name of the shader uniform to animate.
@export var param: StringName = &"progress"
## Value at the start of the cycle.
@export var from: float = 0.0
## Value at the end of the cycle.
@export var to: float = 1.0
## Seconds per cycle.
@export var period: float = 2.0
## 0 = smooth ping-pong, 1 = ramp then hold, 2 = quick pulse, 3 = steps.
@export var mode: int = 0
## Offset of the cycle, 0..1 (to desync several animators).
@export var phase: float = 0.0
## Number of steps for mode 3.
@export var steps: int = 4
## Send the value as an int (for int uniforms).
@export var as_int: bool = false

var enabled: bool = true
var _t: float = 0.0
var _mat: ShaderMaterial = null


func _ready() -> void:
	add_to_group(&"shd_anim")
	var p: Node = get_parent()
	if p is CanvasItem:
		_mat = (p as CanvasItem).material as ShaderMaterial
	_t = phase * period


func _process(delta: float) -> void:
	if not enabled or _mat == null or period <= 0.0:
		return
	_t += delta
	var f: float = fmod(_t / period, 1.0)
	var k: float = 0.0
	match mode:
		0:
			k = 0.5 - 0.5 * cos(f * TAU)
		1:
			k = clampf(f * 1.25, 0.0, 1.0)
		2:
			k = clampf(1.0 - f * 5.0, 0.0, 1.0)
			k = k * k
		3:
			k = floorf(f * float(steps)) / float(maxi(steps - 1, 1))
	var v: float = lerpf(from, to, k)
	if as_int:
		_mat.set_shader_parameter(param, int(roundf(v)))
	else:
		_mat.set_shader_parameter(param, v)
