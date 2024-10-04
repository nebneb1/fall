extends Node2D

@export var viewport : SubViewport
@export var bias : Vector2 = Vector2(0.5, 0.5)

func _process(delta: float):
	position = Vector2(viewport.size) * bias
