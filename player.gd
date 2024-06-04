extends Node3D

const CHIRP_THRESHOLDS = [0.75, 1.5, 2.0]

var is_puppet = false
var id = 1
var chirp_durr : float = 0.0
var is_chirping = false


func _ready() -> void:
	init()

func init():
	if multiplayer.multiplayer_peer != null:
		if not is_puppet:
			id = multiplayer.multiplayer_peer.get_unique_id() 
		else:
			$SFX/enter.play()
		name = str(id)
		
		if not Global.active_players.has(self):
			Global.active_players.append(self)
	
	$VOIPmanager.setup_audio(id)

#func _input(event: InputEvent):
	#if event.is_action_pressed("client") and name == "Player2":
		#queue_free()
func _process(delta: float):
	name = str(id)
	if is_chirping: 
		chirp_durr += delta

@rpc("any_peer", "call_local", "reliable")
func set_voip_status(on : bool):
	$VOIPmanager.is_active = on



@rpc("any_peer", "call_local", "reliable")
func chirp_queue(pressed : bool):
	if is_chirping:
		chirp(chirp_durr)
	
	
	chirp_durr = 0.0
	is_chirping = pressed


func chirp(durration : float):
	set_voip_status.rpc(true)
	durration = clamp(durration, 0.0, CHIRP_THRESHOLDS[2])
	if durration < CHIRP_THRESHOLDS[0]:
		$SFX/chirp_small.play()
	elif durration < CHIRP_THRESHOLDS[1]:
		$SFX/chirp_medium.play()
	else:
		$SFX/chirp_large.play()

func _input(event: InputEvent):
	if not is_puppet:
		if event.is_action_pressed("chirp"):  
			chirp_queue.rpc(true)
		if event.is_action_released("chirp"):  chirp_queue.rpc(false)
