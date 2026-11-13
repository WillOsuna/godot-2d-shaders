extends Node2D
## Demo helper: moves this node back and forth (used by the silhouette demo).

@export var amplitude: Vector2 = Vector2(300.0, 0.0)
@export var period: float = 6.0

var _base: Vector2 = Vector2.ZERO
var _t: float = 0.0


func _ready() -> void:
	_base = position


func _process(delta: float) -> void:
	_t += delta
	position = _base + amplitude * sin(_t * TAU / period)
