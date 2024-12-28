extends Node3D

const SENSITIVITY : Vector2 = Vector2(1.0, 1.0)
const MAX_VELOCITY = 5.0
const Y_ROT_LIMS = [deg_to_rad(-30.0), deg_to_rad(30.0)]
const X_ROT_LIMS = [deg_to_rad(-45.0), deg_to_rad(45.0)]
const X_COMPRESSION = 5.0
const CAMERA_SNAP = 0.01

const DIFF_MULTIPLIER = 2.5

var deadzone = deg_to_rad(3.0)
var target_pull = 6.0
var target_rotation = Vector2.ZERO

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

const SHAKE_AMOUNT = 0.1 
var falling : bool = false
var cam_rot : Vector3

var debug_lock : bool = false

var active_tween1 : Tween = null
var active_tween : Tween = null

var manual_only = false

func _ready():
	#scale = Vector3.ONE * 50.0 
	#Debug.track(self, "rotation")
	randomize()
	Global.camera_holder = self
	Global.camera = camera
	cam_rot = camera.rotation_degrees
	enable()

func disable():
	movement_enabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func enable():
	movement_enabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float):
	#print(target_rotation)
	if velocity.x > 0: velocity.x -= velocity.x*DRAG*delta
	elif velocity.x < 0: velocity.x -= velocity.x*DRAG*delta
	if velocity.y > 0: velocity.y -= velocity.y*DRAG*delta
	elif velocity.y < 0: velocity.y -= velocity.y*DRAG*delta
	
	velocity.y = clamp(velocity.y, -MAX_VELOCITY/2, MAX_VELOCITY/2)
	velocity.x = clamp(velocity.x, -MAX_VELOCITY, MAX_VELOCITY)
	
	rotation.y += velocity.x*delta*SENSITIVITY.x
	rotation.x += velocity.y*delta*SENSITIVITY.y
	
	if not (Global.debug and Input.is_action_pressed("debug")) and not debug_lock:
		if Input.is_action_just_released("debug"):
			print(rotation.x, " ", rotation.y, " ", cam_pos, " ", zoom_target)
		
		if target_rotation.distance_to(Vector2(rotation.x, rotation.y)) > deadzone:
			var dif : Vector2 = Vector2(target_rotation.x-rotation.x, target_rotation.y-rotation.y)
			rotation.x += (dif.x - deadzone * sign(dif.x)) * pow(abs(dif.x * DIFF_MULTIPLIER), 0.5) * target_pull * delta
			rotation.y += (dif.y - deadzone * sign(dif.y)) * pow(abs(dif.y * DIFF_MULTIPLIER), 1) * target_pull * delta
	elif Input.is_action_just_pressed("debug2"):
		debug_lock = !debug_lock
		
		#rotation.y = clamp(rotation.y, X_ROT_LIMS[0], X_ROT_LIMS[1])
		#rotation.x = clamp(rotation.x, Y_ROT_LIMS[0], Y_ROT_LIMS[1])
	
	#rotation.x = clamp(rotation.x + velocity.y * delta * SENSITIVITY.y, X_ROT_LIMS[3], X_ROT_LIMS[0])
	
	
	#if (rotation.x > X_ROT_LIMS[1]):
		#if velocity.y > 0:
			#velocity.y -= DRAG*delta*X_COMPRESSION*(rotation.x-X_ROT_LIMS[1])
		#else:
			#velocity.y -= DRAG*delta*(rotation.x-X_ROT_LIMS[1])
			#
	#if (rotation.x < X_ROT_LIMS[2]):
		#if velocity.y < 0:
			#velocity.y += DRAG*delta*X_COMPRESSION*(X_ROT_LIMS[2]-rotation.x)
		#else:
			#velocity.y += DRAG*delta*(rotation.x-X_ROT_LIMS[2])
	#
	#if (rotation.y > Y_ROT_LIMS[1]):
		#if velocity.x > 0:
			#velocity.x -= DRAG*delta*X_COMPRESSION*(rotation.y-Y_ROT_LIMS[1])
		#else:
			#velocity.x -= DRAG*delta*(rotation.y-Y_ROT_LIMS[1])
			#
	#if (rotation.y < Y_ROT_LIMS[2]):
		#if velocity.x < 0:
			#velocity.x += DRAG*delta*X_COMPRESSION*(Y_ROT_LIMS[2]-rotation.y)
		#else:
			#velocity.x += DRAG*delta*(rotation.y-Y_ROT_LIMS[2])
	#
	#
	#
	#
	
	#camera_ray.target_position = positions["center_view"].position
	#camera_ray.rotation.y = rotation.y
	#camera_ray.rotation.x = rotation.x
	#camera_ray.global_position = global_position
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
	#get_node("../marker").global_position = camera_ray.get_collision_point()
	#get_node("../marker2").global_position = camera_ray.global_position
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


func set_cam_params(rot : Vector2, ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT, trans_type : Tween.TransitionType = Tween.TransitionType.TRANS_SINE, trans_time : float = 2.0, cam_pos_to : Pos = Pos.LEFT_ADJUSTED, zoom : float = 0.0, pull : float = 6.0, deadzone_to : float = 3.0):
	print("cam trans ", rot, " ", ease_type, " ", trans_type, " ", trans_time, " ", cam_pos_to, " ", zoom, " ", pull, " ", deadzone_to)
	if active_tween:
		active_tween.stop()
	if active_tween1:
		active_tween1.stop()
	
	var tween : Tween = create_tween()
	tween.tween_property(self, "target_rotation", rot, trans_time).set_ease(ease_type).set_trans(trans_type)
	active_tween = tween
	cam_pos = cam_pos_to
	if zoom != 0.0: 
		var tween1 : Tween = create_tween()
		tween1.tween_property(self, "zoom_target", zoom, trans_time).set_ease(ease_type).set_trans(trans_type)
		active_tween1 = tween1
	target_pull = pull
	deadzone = deg_to_rad(deadzone_to)
	

func change_cam_area(area : Area3D):
	if not manual_only:
		set_cam_params(area.rot, area.ease_type, area.trans_type, area.trans_time, area.cam_pos, area.zoom, area.pull, area.deadzone)
	#var tween : Tween = create_tween()
	#tween.tween_property(self, "target_rotation", area.rot, area.trans_time).set_ease(area.ease_type).set_trans(area.trans_type)
	#cam_pos = area.cam_pos
	#if area.zoom != 0.0: 
		#var tween1 : Tween = create_tween()
		#tween1.tween_property(self, "zoom_target", area.zoom, area.trans_time).set_ease(area.ease_type).set_trans(area.trans_type)
	#target_pull = area.pull
	#deadzone = deg_to_rad(area.deadzone)


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
	
	if event.is_action_pressed("left") and not Global.player.texting:
		var tween = create_tween()
		tween.tween_property(camera, "position", positions["left_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
		#camera_ray.target_position = positions["left_view"].position
		cam_pos = Pos.LEFT_ADJUSTED
	
	elif event.is_action_pressed("right") and not Global.player.texting:
		var tween = create_tween()
		tween.tween_property(camera, "position", positions["right_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
		#camera_ray.target_position = positions["right_view"].position
		cam_pos = Pos.RIGHT_ADJUSTED
	
	elif event.is_action_pressed("middle") and not Global.player.texting:
		var tween = create_tween()
		tween.tween_property(camera, "position", positions["center_view"].position, TRANS_SPEED).set_ease(Tween.EASE_IN_OUT)
		#camera_ray.target_position = positions["center_view"].position
		cam_pos = Pos.CENTER
	
	if event.is_action_pressed("camera_zoom_in") and not Global.player.texting:
		zoom_target = clamp(zoom_target - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
	
	elif event.is_action_pressed("camera_zoom_out") and not Global.player.texting:
		zoom_target = clamp(zoom_target + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
		
