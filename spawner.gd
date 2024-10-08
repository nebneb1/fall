extends Node3D

const PLAYER_CHANGE_RATE = 10.0
const SPAWN_RADIUS = 50.0

@onready var puppet_player_scene = preload("res://puppet_player.tscn")

var player_count = 0
var player_count_goal = 10


func _ready():
	randomize()

var clock = 0.0
func _process(delta: float):
	clock += delta
	if clock >= PLAYER_CHANGE_RATE:
		clock -= PLAYER_CHANGE_RATE
		if player_count < player_count_goal:
			spawn_puppet_player(get_random_valid_point())
			player_count = get_child_count()
		
		elif player_count > player_count_goal:
			for child in get_children():
				if not Global.camera.is_position_in_frustum(child.global_position):
					child.queue_free()
					break
			
			player_count = get_child_count()
			
			

func get_random_valid_point() -> Vector3:
	var valid_point: Vector3 = Vector3.ZERO
	var player_pos = Global.player.global_position
	while Global.camera.is_position_in_frustum(valid_point) or player_pos.distance_to(valid_point) > SPAWN_RADIUS or valid_point == Vector3.ZERO:
		valid_point = player_pos + Vector3(randf_range(-SPAWN_RADIUS, SPAWN_RADIUS), randf_range(-SPAWN_RADIUS, SPAWN_RADIUS), randf_range(-SPAWN_RADIUS, SPAWN_RADIUS))
	
	return valid_point


func spawn_puppet_player(pos : Vector3):
	var instance = puppet_player_scene.instantiate()
	instance.global_position = pos
	add_child(instance)
