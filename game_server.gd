extends Node

#const INDEX_KEY := {"id":0,"username":1,"met":2,"friends":3}
const PLAYER_PATH = "user://players.txt"
var peer = ENetMultiplayerPeer.new()

var queue : Array = []


func _ready():
	multiplayer.multiplayer_peer.poll()
	print("Server running")
	setup_server()
	if not FileAccess.file_exists(PLAYER_PATH):
		var file = FileAccess.open(PLAYER_PATH, FileAccess.WRITE)
		file.close



func peer_connected(id): 
	print("Peer connected: ", id, " awaiting data")
func peer_disconnected(id): 
	print("Peer disconnected: ", id, " removing from queue")
	for member in queue:
		if member["peer_id"] == id:
			queue.erase(member)


func setup_server():
	var error = peer.create_server(Global.PORT, 4095)
	if error: print("server err: ", error)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	print("server set up on: ", Global.PORT)

@rpc("any_peer", "call_remote", "reliable")
func request_connection(network_info : Dictionary):
	print(network_info["peer_id"], " request ")
	var choices: Array = []
	print("player requests connection:" + str(network_info))
	for player in queue:
		if player["id"] != network_info["id"]: #check if player is self
			var ship = true
			var score = 0
			var shared_languages := []
			
			if not (player["upnp_open"] or network_info["upnp_open"]): # if this is true a connection cannot be made
				ship = false 
			
			if (player["met_recently"].has(network_info["id"]) or network_info["met_recently"].has(player["id"])): # dont want to serve players people they have just met
				ship = false
			
			if player["friends"].has(network_info["id"]) and network_info["friends"].has(player["id"]):  # Friends suprass all boundries :D
				score += 9999999
			
			if player["met_players"].has(network_info["id"]) or network_info["met_players"].has(player["id"]):  # if they have met before, give a massive deduction, we dont want non-friends to meet again unless they have to
				score += -1000
			
			if player["country"] == network_info["country"]: # if they share a country, give a bonus
				score += 20
			
			if player["primary_language"] == network_info["primary_language"]: # if they share the same primary language, give a large bonus, language is more important than country
				score += 10
				shared_languages.append(player["primary_language"])
			
			for language in network_info["language"]: # ppl can relate over shared language
				if player["language"].has(language):
					shared_languages.append(language)
					score += 4
			
			if abs(player["hue"] - network_info["hue"]) < 7: # lol if they have a similar hue, slightly prioritize them
				score += 1
			
			print([score, player, shared_languages, ship])
			if shared_languages.size() > 0 and ship:
				choices.append([score, player, shared_languages])
			
		else: player = network_info
	
	if choices.size() > 0:
		choices.sort_custom(func(a, b): return a[0] > b[0]) # sorting by score
		intitate_connection(network_info, choices[0][1], choices[0][2])
		print("found ", choices[0])
	else: 
		print("none found")
		connect_players.rpc_id(network_info["peer_id"], false, [], "NA") # send back if no one could be found


	#var choices: Array = []
	#for player in queue:
		#if player["id"] != network_info["id"]:
			## this first round is checking for friends 
			#if (player["upnp_open"] or network_info["upnp_open"]) and not (player["friends"].has(network_info["id"]) or network_info["friends"].has(player["id"])) and not (player["met_recently"].has(network_info["id"]) or network_info["met_recently"].has(player["id"])):
				#intitate_connection(network_info, player)
				#return
		#else: player = network_info
	#
	#for player in queue:
		## then other players
		#if (player["id"] != network_info["id"]) and (player["upnp_open"] or network_info["upnp_open"]) and not (player["met_players"].has(network_info["id"]) or network_info["met_players"].has(player["id"])):
				#intitate_connection(network_info, player)
				#return
	
	
			
func intitate_connection(requester : Dictionary, requestee : Dictionary, shared_languages : Array = ["en"]):
	print("connecting ", requestee["username"], ", ", requester["username"])
	if requester["upnp_open"]:
		connect_players.rpc_id(requester["peer_id"], true, shared_languages)
		connect_players.rpc_id(requestee["peer_id"], false, shared_languages, requester["ip"])
	elif requestee["upnp_open"]:
		connect_players.rpc_id(requestee["peer_id"], true, shared_languages)
		connect_players.rpc_id(requester["peer_id"], false, shared_languages, requestee["ip"])
	else:
		print("no avalable host")
	
	await get_tree().create_timer(0.1).timeout
	multiplayer.multiplayer_peer = null

@rpc("authority", "call_remote", "reliable")
func connect_players(is_host : bool, shared_languages : Array, ip : String = "local"):
	pass


@rpc("authority", "call_remote", "reliable")
func set_user_id(id : int):
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func send_network_info(network_info : Dictionary):
	if network_info["id"] == 0:
		while network_info["id"] == 0:
			var players = FileAccess.open(PLAYER_PATH, FileAccess.READ)
			players.seek(0)
			var potential_id = randi_range(1000000, 9999999)
			var is_unique = true
			while !players.eof_reached():
				if int(players.get_line()) == potential_id:
					is_unique = false
					break
			
			if is_unique:
				network_info["id"] = potential_id 
				set_user_id.rpc_id(network_info["peer_id"], network_info["id"])
				var temp = players.get_as_text()
				players.close()
				players = FileAccess.open(PLAYER_PATH, FileAccess.WRITE)
				players.store_string(str(network_info["id"]) + "\n" + temp)
				players.close()
	if not network_info in queue:
		queue.append(network_info)
	
	print(network_info)

@rpc("any_peer", "call_remote", "reliable")
func ping():
	pass



# This feels horribly inefficiant but i dont care! but like i probably will in the future if it starts costing me mone
#func write_db(id : int, index : String, value):
	#var players = FileAccess.open("res://players.txt", FileAccess.READ)
	#var data = players.get_as_text().split("\n") #expensive
	#for player in data: #expensive
		#if player[INDEX_KEY["id"]] == id:
			#var pos = data.find(player) #expensive
			#var player_modify = data[pos].split("|")
			#if index == "username": 
					#player_modify[INDEX_KEY["username"]] = value
			#
			#elif index == "met" or index == "friends": 
				#var arr = player_modify[INDEX_KEY[index]].split(",")
				#
				#if player_modify.has(str(value)):
					#player_modify.remove_at(player_modify.find(str(value)))
				#else: 
					#arr.append(value)
					#
				#player_modify[INDEX_KEY[INDEX_KEY[index]]] = ""
				#for val in arr:
					#player_modify[INDEX_KEY[INDEX_KEY[index]]] += str(val) + ","
			#
			#var arr = data[INDEX_KEY[index]].split("|")
			#data[pos] = ""
			#for val in arr:
				#data[pos] += str(val) + "|"
	#
	#var out = ""
	#for val in data:
		#out += str(val) + "\n" 
	#
	#players.close()
	#players = FileAccess.open("res://players.txt", FileAccess.WRITE)
	#players.store_string(out)
	#players.close()

#var network_info := {
	#"upnp_open": true, 
	#"port": Global.PORT, 
	#"ip": "127.0.0.1",
	#"username": "Player",
	#"id": 0,
	#"met_match": false}

	
	
	
	
	#var players = FileAccess.open("res://players.txt", FileAccess.READ)
	#var met_players := []
	#var friends := []
	#var username := ""
	#if network_info["id"] == 0:
		#while network_info["id"] == 0:
			#players.seek(0)
			#var potential_id = randi_range(1000000, 9999999)
			#var is_unique = true
			#while !players.eof_reached():
				#if int(players.get_line().split("|")[INDEX_KEY["id"]]) == potential_id:
					#is_unique = false
					#break
			
			#if is_unique:
				#network_info["id"] = potential_id 
				#set_user_id.rpc_id(network_info["peer_id"], network_info["id"])
			#
		#
		#
		#var data = str(network_info["id"]) + "|" + network_info["username"] + "|0,|0,|\n" + players.get_as_text()
		#players.close()
		#players = FileAccess.open("res://players.txt", FileAccess.WRITE)
		#players.store_string(data)
		#players.close()
			#
	#else:
		#players.seek(0)
		#var found = false
		#while !players.eof_reached():
			#var line = players.get_line().split("|") # 0|Server|100,200|300,400
			#if int(line[0]) == network_info["id"]:
				#found = true
				#username = line[INDEX_KEY["username"]]
				#for plr in line[INDEX_KEY["met"]].split(","):
					#met_players.append(int(plr))
				#for plr in line[INDEX_KEY["friends"]].split(","):
					#friends.append(int(plr))
			#
		#if not found: 
			#print("player has id (", network_info["id"], ") but is not found in database, this should not happen, panic!!!")
	#
	#if network_info["username"] != username:
		#print("peer has new username, updating in the db")
		#write_db(network_info["id"], "username", network_info["username"])
		#
	#players.close()
	#queue.append([network_info, met_players, friends])


	
