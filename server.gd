extends Node


const PORT = 2556
var peer = ENetMultiplayerPeer.new()

@export var player_scene : PackedScene
@export var room : NodePath

var server_ready : bool =  false


func peer_connected(id):
	print("(server) peer connected: ", id)
	#add_player(id)
	
func peer_disconnected(id):
	print("(server) peer disconnected: ", id)

func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		setup_host()
		print("Hosting on ", PORT)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

func _process(delta: float) -> void:
	if server_ready: peer.poll()

func setup_host():
	var error = peer.create_server(PORT)
	if error: print("server err: ", error)
	
	multiplayer.multiplayer_peer = peer
	
	add_player(1)
	
	server_ready = true

func add_player(id):
	var p = player_scene.instantiate()
	p.id = id
	p.name = str(id)
	get_node(room).add_child(p)
	
	

#func _input(event: InputEvent): if event.is_action_pressed("server"): setup_host()

