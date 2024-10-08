extends CharacterBody3D

# movement
const GRAVITY = -9.8

var terminal_velocity = -20.0
var down_vel = terminal_velocity
var speed_multiplier = 1.0
var vel := Vector2.ZERO
var disable = false
var pair_falling : bool = true

# chirp
@onready var chirp_scene = preload("res://chirp.tscn")
@onready var anim_player = $trail/AnimationPlayer

# username
const MIN_USERNAME_LEN = 3
const MAX_USERNAME_LEN = 32
const DEFAULT_USERNAME = "Traveller"

@onready var username_label : RichTextLabel = get_node("trail/Nametag/SubViewport/Username")

var username = ""

# texting
const MESSAGE_BASE_SEPERATION = 40.0
const MESSAGE_PER_LINE_SEPERATION = 29.0
const MESSAGE_HEIGHT = 0.5

@onready var messages = get_node("Messages")
@onready var text_box_scene = preload("res://text_box.tscn")

var texting : bool = false

var prev_charge = 0.0
func _process(delta: float):
	down_vel += (terminal_velocity-down_vel) * delta
	velocity = Vector3(vel.x, down_vel, vel.y)
	move_and_slide()
	
	$trail/GPUParticles3D13.emitting = pair_falling
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
		

var is_chirping = false
var chirp_durr : float = 0.0
const CHIRP_THRESHOLDS = [0.75, 1.5, 2.0]
const MIN_CHIRP_SIZE = 0.07

func chirp_charge():
	anim_player.play("charge", 0.5)


func chirp(durration : float):
	durration = clamp(durration, 0.0, CHIRP_THRESHOLDS[2])
	if durration < CHIRP_THRESHOLDS[0]:
		$SFX/chirp_small.play()
		anim_player.play("idle", 0.5)

	elif durration < CHIRP_THRESHOLDS[1]:
		anim_player.play("idle", 0.35)
		$SFX/chirp_medium.play()
		
	else:
		anim_player.play("big_chirp", 0.05)
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

func set_username(usr : String):
	username = filter(usr)

#func _input(event: InputEvent):
	#if event.is_action_pressed("chirp") and not disable_chirp and not texting:
		#chirp_queue(true)
		#disable = true
	#
	#if event.is_action_released("chirp") and is_chirping: 
		#chirp_queue(false)
		#disable = false
	#
	#if event.is_action_pressed("chat"):
		#if not pair_falling:
			#if username_input.has_focus():
				#texting = false
				#username_input.text = ""
				#ghost_label.text = username_label.text
				#username_input.release_focus()
			#
			#else:
				#texting = true
				#old_username = username
				#username_input.grab_focus()
		#else:
			#if get_node("Messages/Current"):
				#texting = false
				#var current = get_node("Messages/Current")
				#display_msg(current.text_box.text, 10.0)
				#current.set_readable_only()
				#current.queue_free()
			#else:
				#texting = true
				#var instance = text_box_scene.instantiate()
				#instance.name = "Current"
				#messages.add_child(instance)
				#var child = messages.get_child(messages.get_child_count()-1)
				#child.enable_input()
	#
	#if event.is_action_pressed("escape"):
		#reset_username()
		
		
