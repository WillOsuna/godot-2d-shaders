extends Node2D
## Demo helper: copies the global transform of another node every frame.
## The silhouette demo uses it so a clipped copy of the hero follows the hero.

@export var target: NodePath


func _process(_delta: float) -> void:
	var t: Node2D = get_node_or_null(target) as Node2D
	if t != null:
		global_transform = t.global_transform
