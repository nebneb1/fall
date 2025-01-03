extends Node

const NET_SAVE_DIRECTORY = "user://saves/network.fall"
const SAVE_DIRECTORY = "user://saves/save.fall"
#const BACKUPS = ["user://saves/backup1.fall", "user://saves/backup2.fall"]
const GAME_IDENTIFIER = "under_dream"
const PORT = 25565
const MATCHING_SERVER_IP = "52.53.179.218"

const CONFIRM_CHIRP = 5.0
const emojis = [
	[":heart:", "❤️"], [":skull:", "💀"], [":sparkle:", "✨"], [":blush:", "😊"], [":smile:", "😄"], [":stareyes:", "🤩"],
	[":sweattear:", "😅"], [":joy:", "😂"], [":aw:", "☺️"], [":slightsmile:", "🙂"], [":heartface:", "🥰"],
	[":hearteyes:", "😍"], [":yum:", "😋"], [":crazy:", "🤪"], [":nerd:", "🤓"], [":sunglasses:", "😎"],
	[":stareyes:", "🤩"], [":pensive:", "😞"], [":worried:", "😕"], [":sad:", "🙁"], [":ow:", "😣"],
	[":cry:", "😭"], [":hmph:", "😤"], [":mad:", "😠"], [":angry:", "😡"], [":flushed:", "😳"], 
	[":dispair:", "😓"], [":thinking:", "🤔"], [":stare:", "😐"], [":rly:", "😑"], [":roll:", "🙄"],
	[":woah:", "😯"], [":sleep:", "😴"], [":dizzy:", "😵‍💫"], [":zip:", "🤐"], [":sick:", "🤢"],
	[":shake:", "🤝"], [":thumbsup:", "👍"], [":thumbsdown:", "👎"], [":wave:", "👋"], [":pray:", "🙏"],
	[":eyes:", "👀"], [":grandma:", "👵"], [":grandpa:", "👴"], [":oheart:", "🧡"], [":yheart:", "💛"], 
	[":gheart:", "💚"], [":bheart:", "💙"], [":pheart:", "💜"], [":dheart:", "🖤"], [":wheart:", "🤍"], 
	[":twoheart:", "💕"], [":sparkleheart:", "💖"]
]

var player : CharacterBody3D
var game : Node3D
var camera_holder : Node3D
var camera : Camera3D
var can_fall : bool = false

enum Pos { # for use in camera
	LEFT_ADJUSTED,
	RIGHT_ADJUSTED,
	CENTER
}

var char_pos : Vector2

var active_players : Array = []
var distance = [0, 0]
var distances = [1598809]
var network_info := {
	"upnp_open": true, # if upnp was sucessful
	"port": Global.PORT, # game port
	"ip": "127.0.0.1", # player ip
	"username": "Player", # multiple players can have the same username
	"id": 0, # unique per-player
	"peer_id": 0, # unique per-session, mainly used for networking purposes
	"country": "us", # contry of origin
	"primary_language": "en",
	"language": ["en"], # all languages spoken
	"meet_again": false, # whether meeting the same person is an option
	"met_players": [0], # player ids that have been met before
	"friends": [0], # player ids that have been friended
	"met_recently": [0], # player ids of friends that have been met recently
	"hue": 360, # player hue color (0-360)
	"seed": 99999 # player seed for music
}


#enables all dev stuff so it doesnt get lost and sent thru production
const debug = true
var is_client:  bool = false

func _ready():
	var dir = DirAccess.open("user://") 
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	if FileAccess.file_exists(NET_SAVE_DIRECTORY):
		load_save()

var _previnfo = network_info
func _process(delta):
	if _previnfo != network_info:
		save_game()
	_previnfo = network_info

func save_game():
	var save = FileAccess.open(NET_SAVE_DIRECTORY, FileAccess.WRITE)
	save.store_var(network_info)
	save.close()
	save = FileAccess.open(SAVE_DIRECTORY, FileAccess.WRITE)
	save.store_var(distance) # todo: save this on the server
	save.close()

func load_save():
	var save = FileAccess.open(NET_SAVE_DIRECTORY, FileAccess.READ)
	save.get_var()
	save.close()
	
#func save_backup():
	#var save
	#if FileAccess.file_exists(NET_SAVE_DIRECTORY):
		#save = FileAccess.open(NET_SAVE_DIRECTORY, FileAccess.READ)
		#var temp1 = save.get_as_text()
		#save.close()
		#save = FileAccess.open(BACKUPS[0], FileAccess.READ)
		#var temp2
		#if save != null:
			#temp2 = save.get_as_text()
			#save.close()
			#save = FileAccess.open(BACKUPS[1], FileAccess.WRITE)
			#save.store_string(temp2)
			#save.close()
		#save.close()
		#save = FileAccess.open(BACKUPS[0], FileAccess.WRITE)
		#save.store_string(temp1)
		#save.close()
