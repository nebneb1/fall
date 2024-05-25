extends Node3D

var id = 1

func _ready() -> void: $VOIPmanager.setup_audio(id)

#func _input(event: InputEvent):
	#if event.is_action_pressed("client") and name == "Player2":
		#queue_free()
	
