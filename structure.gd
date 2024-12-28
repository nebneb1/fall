extends Node3D

func move():
	for child in get_children():
		if child is RigidBody3D:
			child.move()
