extends CharacterBody3D

const MAX_PARTICLES = 150.0
const CHARGE_RATE = 5.0

var charge = 0.0

var disable = false


const MAX_SPEED = 5.0
const ACCEL = 1.0
const DRAG = .20
const GRAVITY = -9.8
const TERMINAL_VELOCITY = -20.0
var down_vel = 0.0

var vel := Vector2.ZERO

@export var camera_holder : Node3D
@onready var center = camera_holder.get_node("center_view")
@onready var chirp_scene = preload("res://chirp.tscn")
@onready var anim_player = $trail/AnimationPlayer
@export var sparkle1 : Node3D
@export var sparkle2 : Node3D

func _ready():
	Debug.track(self, "charge")
	if get_parent().is_in_group("player_group"):
		Global.player = self

func _process(delta: float):
	var dir
	if not disable:
		dir = Vector2(
		Input.get_action_strength("forward_move")-Input.get_action_strength("back_move"), 
		Input.get_action_strength("right_move")-Input.get_action_strength("left_move")).normalized().rotated(-camera_holder.global_rotation.y - PI/2.0)
	else:
		dir = Vector2.ZERO
	
	var cam_orientation_vector_forwards = Vector2(center.position.x, center.position.z).normalized()
	var cam_orientation_vector_left = Vector2(center.position.x, center.position.z).normalized().rotated(PI/2.0)
	if vel.length() <= MAX_SPEED:
		vel += dir*ACCEL
	else:
		vel = vel.normalized() * MAX_SPEED
	
	
	if dir.x == 0.0 and vel.x != 0:
		if vel.x > DRAG: vel.x -= DRAG * delta * 60.0
		elif vel.x < -DRAG: vel.x += DRAG * delta * 60.0
		else: vel.x = 0
	
	if dir.y == 0.0 and vel.y != 0:
		if vel.y > DRAG: vel.y -= DRAG * delta * 60.0
		elif vel.y < -DRAG: vel.y += DRAG * delta * 60.0
		else: vel.y = 0
	
	if not is_on_floor():
		down_vel = clamp(down_vel + delta*GRAVITY*(1-(down_vel/TERMINAL_VELOCITY)), TERMINAL_VELOCITY, 10.0)
	else:
		down_vel = 0
	
	velocity = Vector3(vel.x, down_vel, vel.y)
	#$trail.amount = 100 * (Vector3(vel.x, 0, vel.y).length())
	#print($trail.amount)
	if charging:
		charge = clamp(charge + delta/CHARGE_RATE, 0.0, 1.0)
	
	
	for i in range(sparkle1.get_child_count()):
		sparkle1.get_child(i).emitting = i+1 < snapped(charge, 0.1) * 10.0
	
	for i in range(sparkle2.get_child_count() - 1):
		sparkle2.get_child(i).emitting = i+1 < snapped(charge, 0.1) * 10.0
	
	move_and_slide()
	
	chirp_durr += delta
	
	
	
	if dir.length() !=  0.0:
		for i in range(sparkle1.get_child_count() - 1):
			sparkle1.get_child(i).rotation.y = -dir.angle() - PI/2

func _input(event: InputEvent):
	if event.is_action_pressed("chirp") and not disable_chirp:  
		chirp_queue(true)
		disable = true
	if event.is_action_released("chirp") and is_chirping: 
		chirp_queue(false)
		disable = false
		

var is_chirping = false
var chirp_durr : float = 0.0
var disable_chirp : bool = false
const CHIRP_THRESHOLDS = [0.75, 1.5, 2.0]
const MIN_CHIRP_SIZE = 0.07

func chirp_queue(pressed : bool):
	if is_chirping:
		chirp(chirp_durr)
	
	if pressed:
		anim_player.play("charge", 0.5)
		for child in sparkle1.get_children():
			child.tangential_accel_max = 100.0
	else:
		for child in sparkle1.get_children():
			child.tangential_accel_max = 0.0
	chirp_durr = 0.0
	is_chirping = pressed



func chirp(durration : float):
	durration = clamp(durration, 0.0, CHIRP_THRESHOLDS[2])
	if durration < CHIRP_THRESHOLDS[0]:
		$SFX/chirp_small.play()
		anim_player.play("idle", 0.5)
		charge *= 0.75 
	elif durration < CHIRP_THRESHOLDS[1]:
		disable_chirp = true
		if charge >= 0.2:
			$trail/sparkles3.emitting = true
			if activatable:
				activate_object.activate()
		$chirp_cooldown.start(0.75)
		anim_player.play("idle", 0.35)
		charge *= 0.4 
		$SFX/chirp_medium.play()
		
	else:
		disable_chirp = true
		if charge >= 0.2:
			$trail/sparkles4.emitting = true
			if activatable:
				activate_object.activate()
		$chirp_cooldown.start(1.5)
		anim_player.play("big_chirp", 0.05)
		charge = 0
		$SFX/chirp_large.play()
	
	var instance = chirp_scene.instantiate()
	instance.chirp_size = (durration / CHIRP_THRESHOLDS[2]) * (1.0-MIN_CHIRP_SIZE) + MIN_CHIRP_SIZE
	#instance.global_position = $trail.global_position
	#Global.game.add_child(instance)
	add_child(instance)


var charging = false
var activatable = false
var activate_object = null
func _on_flow_area_entered(area: Area3D) -> void:
	if area.is_in_group("flow"):
		charging = true
	if area.is_in_group("activate"):
		activatable = true 
		activate_object = area.get_parent()


func _on_flow_area_exited(area: Area3D) -> void:
	if area.is_in_group("flow"):
		charging = false
	if area.is_in_group("activate"):
		activatable = false




func _on_chirp_cooldown_timeout() -> void:
	if disable_chirp:
		anim_player.play("idle", 0.5)
		disable_chirp = false
