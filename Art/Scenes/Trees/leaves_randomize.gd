extends Node3D

@export var randomness = 1.0

func _ready():
	randomize()
	position += Vector3(randf_range(-randomness, randomness), randf_range(-randomness, randomness/2.0), randf_range(-randomness, randomness))
