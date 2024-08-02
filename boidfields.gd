extends Node3D
@onready var boid_scene = preload("res://boid.tscn")
@export var camera : Camera3D

const DIMENTIONS = Vector3(7, 7, 7)
const SEPERATION = 20.0

func _ready() -> void:
	spawn_boids()
	
	
func spawn_boids():
	var spawn_pos = Vector3.ZERO
	var count = 0
	for x in range(DIMENTIONS.x): 
		for y in range(DIMENTIONS.y): 
			for z in range(DIMENTIONS.z):
				var inst = boid_scene.instantiate()
				inst.global_position = Vector3(x,y,z) * SEPERATION
				inst.id = count
				inst.camera = camera
				add_child(inst)
				
				count += 1
		
		
#const MAX_SPEED = 10.0
#var vel = 0.0
#func _process(delta: float) -> void:
	#vel = clamp((vel-1.0*delta), -MAX_SPEED, MAX_SPEED)
	#global_position.y -= vel
