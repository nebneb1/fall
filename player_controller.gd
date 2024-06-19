extends CharacterBody3D

const MAX_SPEED = 5.0
const ACCEL = 1.0
const DRAG = .20
const GRAVITY = -9.8
const TERMINAL_VELOCITY = -20.0
var down_vel = 0.0

var vel := Vector2.ZERO

@export var camera_holder : Node3D
@onready var center = camera_holder.get_node("center_view")

func _ready():
	if get_parent().is_in_group("player_group"):
		Global.player = self

func _process(delta: float):
	var dir = Vector2(
	Input.get_action_strength("forward_move")-Input.get_action_strength("back_move"), 
	Input.get_action_strength("right_move")-Input.get_action_strength("left_move")).normalized().rotated(-camera_holder.global_rotation.y - PI/2.0)
	var cam_orientation_vector_forwards = Vector2(center.position.x, center.position.z).normalized()
	var cam_orientation_vector_left = Vector2(center.position.x, center.position.z).normalized().rotated(PI/2.0)
	if vel.length() <= MAX_SPEED:
		vel += dir*ACCEL
	else:
		vel = vel.normalized() * MAX_SPEED
	
	
	if dir.x == 0.0 and vel.x != 0:
		if vel.x > DRAG: vel.x -= DRAG
		elif vel.x < -DRAG: vel.x += DRAG
		else: vel.x = 0
	
	if dir.y == 0.0 and vel.y != 0:
		if vel.y > DRAG: vel.y -= DRAG
		elif vel.y < -DRAG: vel.y += DRAG
		else: vel.y = 0
	
	if not is_on_floor():
		down_vel = clamp(down_vel + delta*GRAVITY*(1-(down_vel/TERMINAL_VELOCITY)), TERMINAL_VELOCITY, 10.0)
	else:
		down_vel = 0
	
	velocity = Vector3(vel.x, down_vel, vel.y)
	#$trail.amount = 100 * (Vector3(vel.x, 0, vel.y).length())
	#print($trail.amount)
	move_and_slide()
	
	if dir.length() !=  0.0:
		$trail/sparkles.rotation.y = -dir.angle() - PI/2

func _input(event: InputEvent):
	if event.is_action_pressed("chirp"):
		$trail/sparkles3.emitting = true
