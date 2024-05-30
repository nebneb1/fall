extends Node

const SAVE_DIRECTORY = "C:/Users/%USERNAME%/AppData/Local/Fall/Save/save.fall"
const GAME_IDENTIFIER = "under_dream_upnp"
const PORT = 25564
const MATCHING_SERVER_IP = "127.0.0.1"


var network_info := {
	"upnp_open": true, # if upnp was sucessful
	"port": Global.PORT, # game port
	"ip": "127.0.0.1", # player ip
	"username": "Player", # multiple players can have the same username
	"id": 0, # unique per-player
	"peer_id": 0, # unique per-session, mainly used for networking purposes
	"country": "", # contry of origin
	"primary_language": "",
	"language": [], # all languages spoken
	"meet_again": false, # whether meeting the same person is an option
	"met_players": [0], # player ids that have been met before
	"friends": [0], # player ids that have been friended
	"met_recently": [0], # player ids of friends that have been met recently
	"hue": 360, # player hue color (0-360)
	"seed": 99999 # player seed for music
	}
