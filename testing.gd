extends Node

#func _input(event: InputEvent):
	#if event.is_action_pressed("client"):
		#get_tree().change_scene_to_file("res://client.tscn")
	#elif event.is_action_pressed("server"):
		#get_tree().change_scene_to_file("res://server.tscn")
