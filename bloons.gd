extends Node3D

const TRANSPARENCY_TRANSSITION_SPEED = 0.2

const MAX_ROTATION_MOMENTUM = 100.0
const ROTATION_TIMER_RANGE = [7.0, 15.0]
const ROTATION_MOMENTUM_SPEED = 1.0
var rotation_timer = 0.0
var rotation_timer_goal = 1.0
var rotation_momentum_goal = 0.0
var rotation_momentum = 0.0

const MOVE_TARGET_SPEED = 5.0

@export var type : String = "crea"
var meshes : Array = []

var string : MeshInstance3D

func _ready() -> void:
	randomize()
	string = get_parent()
	for child in get_children():
		if child.name == type:
			child.show()
			for child1 in child.get_children():
				meshes.append(child1.get_active_material(0))
		elif not child.is_in_group("show"):
			child.hide()



func _process(delta: float) -> void:
	rotation_timer += delta
	if rotation_timer >= rotation_timer_goal:
		rotation_timer -= rotation_timer_goal
		rotation_timer_goal = randf_range(ROTATION_TIMER_RANGE[0], ROTATION_TIMER_RANGE[1])
		rotation_momentum_goal = randf_range(-MAX_ROTATION_MOMENTUM, MAX_ROTATION_MOMENTUM)
	
	rotation_momentum = lerp(rotation_momentum, rotation_momentum_goal, delta * ROTATION_MOMENTUM_SPEED)
	rotation_degrees.y += rotation_momentum * delta
	
	position = position.lerp(string.points[-1], delta * MOVE_TARGET_SPEED)
	var player_pos = Global.player.global_position
	player_pos.y = global_position.y
	#look_at(player_pos)
	#rotation_degrees.x = 90
	for mat in meshes:
		mat.albedo_color.a = lerp(mat.albedo_color.a, float(Global.player.is_chirping), delta * TRANSPARENCY_TRANSSITION_SPEED)
		#print(mesh.get("albedo_color"))
