extends Node3D

var fog = []
@onready var clouds_scene = preload("res://clouds.tscn")
@export var fog_holder : Node3D

const MAX_FOG_AGE = 3

func _ready() -> void:
	Global.camera_holder.falling = true
	

func update_fog():
	var remove = -1
	if fog.size() != 0:
		for i in range(fog.size() - 1):
			fog[i][0] += 1
			if fog[i][0] >= MAX_FOG_AGE:
				fog[i][1].queue_free()
				remove = i
	
	if remove != -1:
		fog.remove_at(remove)
	
	var clouds = clouds_scene.instantiate()
	clouds.global_position = Vector3(Global.player.global_position.x, Global.player.global_position.y - clouds.size.y * 1.5, Global.player.global_position.z)
	
	fog_holder.add_child(clouds)
	fog.append([0, fog_holder.get_child(fog_holder.get_child_count()-1)])


		
	
	
