extends Node3D

func move():
	for child in get_children():
		child.move()
