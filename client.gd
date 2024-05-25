extends Node

const ADDRESS = "127.0.0.1" 
const PORT = 2556

var peer = ENetMultiplayerPeer.new()

@export var player_scene : PackedScene
@export var room : NodePath

var clientConnected : bool = false

func peer_connected(id):
	print("(client) peer connected: ", id)
	add_player(id)
	
func peer_disconnected(id):
	print("(client) peer disconnected: ", id)

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

func _process(delta):
	if clientConnected:
		peer.poll()


func setup_client():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
	add_player(multiplayer.get_unique_id())
	
	clientConnected = true
	
func add_player(id):
	var p = player_scene.instantiate()
	p.id = id
	p.name = str(id)
	get_node(room).add_child(p)

func _input(event: InputEvent): if event.is_action_pressed("client"): setup_client()
