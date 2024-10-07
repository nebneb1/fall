extends CharacterBody3D

# movement
const MAX_SPEED = 5.0
const ACCEL = 1.0
const DRAG = .20
const GRAVITY = -9.8
const TERMINAL_VELOCITY = -20.0
const RETURN_SPEED = 100.0
const RETURN_TIME = 5.0
const FALLING_MULT = 0.5

@export var camera_holder : Node3D
@onready var center = camera_holder.get_node("center_view")

var down_vel = 0.0
var speed_multiplier = 1.0
var vel := Vector2.ZERO
var disable = false
var pair_falling : bool = true

# chirp
@onready var chirp_scene = preload("res://chirp.tscn")
@onready var anim_player = $trail/AnimationPlayer


# flow
const CHARGE_RATE = 5.0

@export var sparkle1 : Node3D
@export var sparkle2 : Node3D

var charge = 1.0

# username
const MIN_USERNAME_LEN = 3
const MAX_USERNAME_LEN = 32
const DEFAULT_USERNAME = "Traveller"

@export var username_input : TextEdit
@onready var username_label : RichTextLabel = get_node("trail/Nametag/SubViewport/Username")
@onready var ghost_label : RichTextLabel = get_node("trail/Nametag/SubViewport/Ghost")

var username = ""
var old_username = ""

# texting
const MESSAGE_BASE_SEPERATION = 40.0
const MESSAGE_PER_LINE_SEPERATION = 29.0
const MESSAGE_HEIGHT = 0.5

@onready var messages = get_node("Messages")
@onready var text_box_scene = preload("res://text_box.tscn")

var texting : bool = false

func _ready():
	Debug.track(self, "charge")
	if get_parent().is_in_group("player_group"):
		Global.player = self
var dir : Vector2

var prev_charge = 0.0
func _process(delta: float):
	# movement
	dir = Vector2.ZERO
	if not disable and not texting:
		dir = Vector2(
		Input.get_action_strength("forward_move")-Input.get_action_strength("back_move"), 
		Input.get_action_strength("right_move")-Input.get_action_strength("left_move")).normalized().rotated(-camera_holder.global_rotation.y - PI/2.0)
	else:
		dir = Vector2.ZERO
	
	#var cam_orientation_vector_forwards = Vector2(center.position.x, center.position.z).normalized()
	#var cam_orientation_vector_left = Vector2(center.position.x, center.position.z).normalized().rotated(PI/2.0)
	if vel.length() <= MAX_SPEED * speed_multiplier:
		vel += dir*ACCEL* speed_multiplier
	else:
		vel = vel.normalized() * MAX_SPEED * speed_multiplier
	
	
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
		speed_multiplier = FALLING_MULT
		if charge > 0.0:
			charge = clamp(charge - delta/CHARGE_RATE/2.0, 0.0, 1.0)
	else:
		down_vel = 0
		speed_multiplier = 1.0
	
	#if returning:
		#var return_vector : Vector3 = global_position.direction_to(return_pos.global_position).normalized()
		#return_vector *= RETURN_SPEED
		#print(return_vector)
		#vel.x += return_vector.x * delta
		#vel.y += return_vector.z * delta
		#down_vel = return_vector.y * delta
		#return_timer += delta
		#if return_timer > RETURN_TIME:
			#return_timer = 0
			#returning = false
	
	velocity = Vector3(vel.x, down_vel, vel.y)
	#$trail.amount = 100 * (Vector3(vel.x, 0, vel.y).length())
	#print($trail.amount)
	if charging:
		charge = clamp(charge + delta/CHARGE_RATE, 0.0, 1.0)
	
	
	for i in range(sparkle1.get_child_count()):
		sparkle1.get_child(i).emitting = i < snapped(charge, 0.1) * 10.0
	
	for i in range(sparkle2.get_child_count() - 1):
		sparkle2.get_child(i).emitting = i < snapped(charge, 0.1) * 10.0
	
	$trail/GPUParticles3D11.emitting = charge > prev_charge and is_on_floor()
	$trail/GPUParticles3D12.emitting = not is_on_floor()
	#$trail/GPUParticles3D13.emitting = pair_falling
	
	#print($trail/GPUParticles3D11.emitting,
	#$trail/GPUParticles3D12.emitting,
	#$trail/GPUParticles3D13.emitting,prev_charge)
	prev_charge = charge
		
	move_and_slide()
	
	if is_chirping:
		chirp_durr += delta
	
	
	
	if dir.length() !=  0.0:
		for i in range(sparkle1.get_child_count() - 1):
			sparkle1.get_child(i).rotation.y = -dir.angle() - PI/2
	
	
	
	if username_input.has_focus():
		disable = true
		username_input.text = filter(username_input.text)
		if len(username_input.text) > MAX_USERNAME_LEN:
			username_input.text = username_input.text.erase(len(username_input.text)-1)
		username_input.set_caret_column(len(username_input.text))
		username = username_input.text
		username_label.text = "[center]" + username
	
	var ydisplace = MESSAGE_HEIGHT
	var children = messages.get_children()
	children.reverse()
	for textbox in children:
		textbox.position.y = ydisplace
		ydisplace += textbox.pixel_size * ((textbox.get_num_lines() * MESSAGE_PER_LINE_SEPERATION) + MESSAGE_BASE_SEPERATION)
	
	
const USERNAME_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*_+()[]{}|\\;:\"\'<>?,./ "
func filter(text : String):
	var out = ""
	for char in text:
		if char in USERNAME_CHARS:
			out += char
	
	return out
		
func reset_username():
	if old_username == "":
			old_username = DEFAULT_USERNAME
		
	username = old_username
	username_label.text = "[center]" + username
	ghost_label.text = username_label.text

func _input(event: InputEvent):
	if event.is_action_pressed("chirp") and not disable_chirp and not texting:
		chirp_queue(true)
		disable = true
	
	if event.is_action_released("chirp") and is_chirping: 
		chirp_queue(false)
		disable = false
	
	if event.is_action_pressed("chat"):
		if not pair_falling:
			if username_input.has_focus():
				texting = false
				username_input.text = ""
				ghost_label.text = username_label.text
				username_input.release_focus()
			
			else:
				texting = true
				old_username = username
				username_input.grab_focus()
		else:
			if get_node("Messages/Current"):
				texting = false
				var current = get_node("Messages/Current")
				display_msg(current.text_box.text, 10.0)
				current.set_readable_only()
				current.queue_free()
			else:
				texting = true
				var instance = text_box_scene.instantiate()
				instance.name = "Current"
				messages.add_child(instance)
				var child = messages.get_child(messages.get_child_count()-1)
				child.enable_input()
	
	if event.is_action_pressed("escape"):
		reset_username()
		
		

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

func display_msg(msg : String, fade_time : float = 0.0):
	var instance = text_box_scene.instantiate()
	messages.add_child(instance)
	var child = messages.get_child(messages.get_child_count()-1)
	child.set_readable_only()
	child.text_box.text = msg
	child.call_deferred("find_minimum_border_size")
	if fade_time != 0.0:
		child.free_in_time(fade_time)
	


var charging = false
var activatable = false
var activate_object = null
func _on_flow_area_entered(area: Area3D) -> void:
	if area.is_in_group("flow"):
		charging = true
	if area.is_in_group("activate"):
		activatable = true 
		activate_object = area.get_parent()
		
	if area.is_in_group("falling"):
		if Global.can_fall:
			Trans.scene("fall", "fog_fade", 10.0)
		else:
			Trans.fake_trans(Callable(self, "reset_pos"), "fog_fade", 10.0)

func reset_pos():
	global_position = get_parent().reset_point.global_position

func _on_flow_area_exited(area: Area3D) -> void:
	if area.is_in_group("flow"):
		charging = false
	if area.is_in_group("activate"):
		activatable = false




func _on_chirp_cooldown_timeout() -> void:
	if disable_chirp:
		anim_player.play("idle", 0.5)
		disable_chirp = false


func _on_text_input_focus_entered() -> void:
	pass


func _on_text_input_focus_exited() -> void:
	if not len(username) >= MIN_USERNAME_LEN or not len(username) <= MAX_USERNAME_LEN:
		reset_username()
	
	Global.network_info["username"] = username
	disable = false
