extends Node3D

@export var player_scene : PackedScene
@onready var player = get_node("Player")

func _ready():
	Global.game = self
	#get_tree().set_auto_accept_quit(false)
	#setup_upnp()
	#await get_tree().create_timer(3.0).timeout
	#print(connect_to_server(Global.MATCHING_SERVER_IP, Global.PORT))
	#await get_tree().create_timer(3.0).timeout
	#print("rdy to request")
	
func _process(delta: float):
	if Global.active_players.size() > 1 and Global.active_players[0].chirp_durr >= Global.CONFIRM_CHIRP and Global.active_players[1].chirp_durr >= Global.CONFIRM_CHIRP:
		Global.active_players[0].set_voip_status.rpc(true)
		Global.active_players[1].set_voip_status.rpc(true)
	
#func _input(event: InputEvent):
	#if event.is_action_pressed("request"):
		#print("request sent to server")
		#request_connection.rpc(Global.network_info)
		#
	#if event.is_action_pressed("server"):
		#print("server set up")
		#connect_players(true, ["en"], "127.0.0.1")
		#Global.is_client = false
	#
	#if event.is_action_pressed("client"):
		#connect_players(false, ["en"], "127.0.0.1")
		#Global.is_client = true


# below here is stuff to handle various networking things
func host_server(port : int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Global.PORT, 2)
	multiplayer.multiplayer_peer = peer
	Global.network_info["peer_id"] = peer.get_unique_id()

func connect_to_server(ip : String, port : int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	Global.network_info["peer_id"] = peer.get_unique_id()
	multiplayer.connected_to_server.connect(on_connect)
	return err

func on_connect():
	send_network_info.rpc(Global.network_info)

@rpc("authority", "call_remote", "reliable")
func set_user_id(id : int):
	Global.network_info["id"] = id

var host
@rpc("authority", "call_remote", "reliable")
func connect_players(is_host : bool, shared_languages : Array, ip : String = "local"):
	if ip == "NA":
		return
	elif is_host:
		multiplayer.multiplayer_peer = null
		await get_tree().create_timer(1.0).timeout
		host_server(Global.PORT)
		host = is_host
	else:
		multiplayer.multiplayer_peer = null
		host = is_host
		for time in [2.0, 5.0, 10.0]: # Trying 3 times
			await get_tree().create_timer(time).timeout
			if connect_to_server(ip, Global.PORT) != ERR_CANT_CONNECT:
				break
		await get_tree().create_timer(0.5).timeout
		ping.rpc()
	

@rpc("any_peer", "call_remote", "reliable")
func ping():
	if host:
		print("Hi client!! this server")
		ping.rpc()
	else:
		print("Hi server!! this client, we r p2p and its cool")
	
	add_player(multiplayer.get_remote_sender_id())
	add_player(multiplayer.get_unique_id(), false)
	#get_node("1").id = multiplayer.get_unique_id()
	#Global.active_players[0].init()

func add_player(id : int, is_puppet : bool = true):
	var p = player_scene.instantiate()
	p.id = id
	p.name = str(id)
	p.is_puppet = is_puppet
	add_child(p)
	print("added " + p.name)

@rpc("any_peer", "call_remote", "reliable")
func send_network_info(network_info : Dictionary):
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func request_connection(network_info : Dictionary):
	pass

#upnp to remove need for port forwarding
var upnp = UPNP.new()
func setup_upnp():
	var discover_result = upnp.discover()
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
			var map_result_udp = upnp.add_port_mapping(Global.PORT, 0, Global.GAME_IDENTIFIER + "_UDP", "UDP", 0)
			var map_result_tcp = upnp.add_port_mapping(Global.PORT, 0, Global.GAME_IDENTIFIER + "_TCP", "TCP", 0)
			
			if map_result_udp != UPNP.UPNP_RESULT_SUCCESS: # checking if it works with/without discription
				map_result_udp = upnp.add_port_mapping(Global.PORT, 0, "", "UDP")
			if map_result_tcp != UPNP.UPNP_RESULT_SUCCESS:
				map_result_tcp = upnp.add_port_mapping(Global.PORT, 0, "", "TCP")
			
			if map_result_tcp != UPNP.UPNP_RESULT_SUCCESS or map_result_udp != UPNP.UPNP_RESULT_SUCCESS:
				print("UPNP setup failed with error codes " + str(map_result_tcp) + ", " + str(map_result_udp))
				Global.network_info["upnp_open"] = false
			
		else:
			print("UPNP setup failed")
			Global.network_info["upnp_open"] = false
	
	else: 
		print("UPNP discovery failure")
		Global.network_info["upnp_open"] = false
	
	if Global.network_info["upnp_open"]:
		Global.network_info["ip"] = upnp.query_external_address()
		print("UPNP setup sucess, port " + str(Global.network_info["port"]) + " forwarded")

#close ports on app close
func close_ports():
	if Global.network_info["upnp_open"]:
		var sucess = [upnp.delete_port_mapping(Global.PORT, "UDP"), upnp.delete_port_mapping(Global.PORT, "TCP")]
		if sucess[0] == UPNP.UPNP_RESULT_SUCCESS and sucess[1] == UPNP.UPNP_RESULT_SUCCESS: 
			print("Port closing successful")
			Global.network_info["upnp_open"] = false
		else: 
			print("Port closing unsuccessful")


var quitting = false
func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not quitting:
		quitting = true
		Global.save_game()
		#Global.save_backup()
		close_ports()
		await get_tree().create_timer(2.0).timeout # make sure that everything goes through, should be near immediate but better safe than sorry !
		get_tree().quit()



