extends Node3D

const SENSITIVITY : Vector2 = Vector2(1.0, 1.0)
const MAX_VELOCITY = 5.0
const X_ROT_LIMS = [deg_to_rad(45.0), deg_to_rad(35.0), deg_to_rad(-15.0), deg_to_rad(-22.0)]
const X_COMPRESSION = 5.0
const CAMERA_SNAP = 0.01

const MIN_ZOOM = 0.2
const MAX_ZOOM = 0.75
const ZOOM_STEP = 0.1
const ZOOM_SPEED = 2.0
var zoom_target = MAX_ZOOM

@onready var camera = $Camera3D
@export var camera_ray : RayCast3D
@export var player : CharacterBody3D
@onready var positions : Dictionary = {
	"center_view": $center_view,
	"right_view": $right_view,
	"left_view": $left_view
}


var movement_enabled : bool = false
var disable_y : bool = false

enum Pos {
	LEFT_ADJUSTED,
	RIGHT_ADJUSTED,
	CENTER
}
@export var cam_pos : Pos = Pos.LEFT_ADJUSTED
var target : Vector3 = Vector3.ZERO 
var cam_height = 3.785/2
var cam_height_mod = 1.0

var velocity : Vector2 = Vector2.ZERO
#var momentum := Vector3.ZERO
const DRAG = 10.0
const TRANS_SPEED = 1.5

const SHAKE_AMOUNT = 0.03 
var falling : bool = false
var cam_rot : Vector3


func _ready():
	randomize()
	Global.camera_holder = self
	cam_rot = camera.rotation_degrees
	enable()

func disable():
	movement_enabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func enable():
	movement_enabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float):
	velocity.x = clamp(velocity.x, -MAX_VELOCITY, MAX_VELOCITY)
	rotate_y(velocity.x*delta*SENSITIVITY.x)
	if velocity.x > 0: velocity.x -= velocity.x*DRAG*delta
	elif velocity.x < 0: velocity.x -= velocity.x*DRAG*delta
	
	
	velocity.y = clamp(velocity.y, -MAX_VELOCITY/2, MAX_VELOCITY/2)
	
	rotation.x = clamp(rotation.x + velocity.y * delta * SENSITIVITY.y, X_ROT_LIMS[3], X_ROT_LIMS[0])
	
	
	if (rotation.x > X_ROT_LIMS[1]):
		if velocity.y > 0:
			velocity.y -= DRAG*delta*X_COMPRESSION
		else:
			velocity.y -= DRAG*delta
			
	if (rotation.x < X_ROT_LIMS[2]):
		if velocity.y < 0:
			velocity.y += DRAG*delta*X_COMPRESSION
		else:
			velocity.y += DRAG*delta
	
	if velocity.y > 0: velocity.y -= velocity.y*DRAG*delta
	elif velocity.y < 0: velocity.y -= velocity.y*DRAG*delta
	
	camera_ray.target_position = positions["center_view"].position
	camera_ray.rotation.y = rotation.y
	camera_ray.rotation.x = rotation.x
	camera_ray.global_position = global_position
	#if camera_ray.is_colliding():
		#camera.global_position =  lerp(camera.global_position, camera_ray.get_collision_point()*0.8, 0.2)
	if true: #else:
		match cam_pos:
			Pos.LEFT_ADJUSTED:
				camera.position = lerp(camera.position, positions["left_view"].position, delta)
			
			Pos.RIGHT_ADJUSTED:
				camera.position = lerp(camera.position, positions["right_view"].position, delta)
				
			Pos.CENTER:
				camera.position = lerp(camera.position, positions["center_view"].position, delta)
		#
	if abs(zoom_target - scale.x) > 0.001:
		if zoom_target - scale.x > 0:
			scale += Vector3.ONE * delta * ZOOM_SPEED * abs(scale.x-zoom_target)
		else:
			scale -= Vector3.ONE * delta * ZOOM_SPEED * abs(scale.x-zoom_target)
	
	else:
		scale = Vector3.ONE*zoom_target
	get_node("../marker").global_position = camera_ray.get_collision_point()
	get_node("../marker2").global_position = camera_ray.global_position
	#else:
		#match cam_pos:
			#Pos.LEFT_ADJUSTED:
				#var tween = create_tween()
				#tween.tween_property(camera, "position", positions["left_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
			#
			#Pos.RIGHT_ADJUSTED:
				#var tween = create_tween()
				#tween.tween_property(camera, "position", positions["right_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
				#
			#Pos.CENTER:
				#var tween = create_tween()
				#tween.tween_property(camera, "position", positions["center_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
	if not falling:
		global_position = global_position.lerp(Vector3(player.global_position.x, player.global_position.y + cam_height*scale.x*cam_height_mod, player.global_position.z), delta*5.0)
	else: 
		global_position = Vector3(player.global_position.x, player.global_position.y + cam_height*scale.x*cam_height_mod, player.global_position.z)
		camera.rotation_degrees = cam_rot + Vector3(randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT), randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT), 0.0) 
	
	
		
	
	

func _input(event: InputEvent):
	if event is InputEventMouseMotion and movement_enabled:
		velocity.x += deg_to_rad(-event.relative.x)
		if not disable_y:
			velocity.y += deg_to_rad(event.relative.y)
	
	elif event.is_action_pressed("escape"):
		if movement_enabled:
			disable()
		else:
			enable()
	
	if event.is_action_pressed("left"):
		var tween = create_tween()
		tween.tween_property(camera, "position", positions["left_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
		camera_ray.target_position = positions["left_view"].position
		cam_pos = Pos.LEFT_ADJUSTED
	
	elif event.is_action_pressed("right"):
		var tween = create_tween()
		tween.tween_property(camera, "position", positions["right_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
		camera_ray.target_position = positions["right_view"].position
		cam_pos = Pos.RIGHT_ADJUSTED
	
	elif event.is_action_pressed("middle"):
		var tween = create_tween()
		tween.tween_property(camera, "position", positions["center_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
		camera_ray.target_position = positions["center_view"].position
		cam_pos = Pos.CENTER
	
	if event.is_action_pressed("camera_zoom_in"):
		zoom_target = clamp(zoom_target - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
	
	elif event.is_action_pressed("camera_zoom_out"):
		zoom_target = clamp(zoom_target + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
		
