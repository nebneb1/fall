extends Node3D

func _ready():
	setup_upnp()
	connect_to_matching_server()
	request_connection.rpc(Global.network_info["id"])
		
	

# below here is stuff to handle various networking things

var peer = ENetMultiplayerPeer.new()
func connect_to_matching_server():
	peer.create_client(Global.MATCHING_SERVER_IP, Global.PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	Global.network_info["peer_id"] = peer.get_unique_id()
	

func peer_connected(id): print("Peer connected: ", id)
func peer_disconnected(id): print("Peer disconnected: ", id)

@rpc("authority", "call_remote", "reliable")
func set_user_id(id : int):
	Global.network_info["id"] = id

@rpc("any_peer", "call_remote", "reliable")
func request_id(peer_id):
	pass

@rpc("any_peer", "call_remote", "reliable")
func send_network_info(network_info : Array):
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
	
	if Global.network_info["upnp_open"]:
		Global.network_info["ip"] = upnp.query_external_address()
		print("UPNP setup sucess, port " + str(Global.network_info["port"]) + " forwarded")


#close ports on app close
func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST and Global.network_info["upnp_open"]:
		var sucess = [upnp.delete_port_mapping(Global.PORT, "UDP"), upnp.delete_port_mapping(Global.PORT, "TCP")]
		if sucess[0] == UPNP.UPNP_RESULT_SUCCESS and sucess[1] == UPNP.UPNP_RESULT_SUCCESS: 
			print("Port closing successful")
			Global.network_info["upnp_open"] = false
		else: print("Port closing unsuccessful")



