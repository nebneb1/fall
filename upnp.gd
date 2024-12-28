extends Node2D

func _ready() -> void:
	setup_upnp()

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
				#Global.network_info["upnp_open"] = false
			
		else:
			print("UPNP setup failed")
			#Global.network_info["upnp_open"] = false
	
	else: 
		print("UPNP discovery failure")
		#Global.network_info["upnp_open"] = false
	
	if Global.network_info["upnp_open"]:
		#Global.network_info["ip"] = upnp.query_external_address()
		print("UPNP setup sucess, port " + str(Global.network_info["port"]) + " forwarded")
