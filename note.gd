extends AudioStreamPlayer

const INSTRUMENTS_DIRECTORY = "res://Audio/Music/Instruments/"
const FADE_OUT_SPEED = 5.0

var instrument = "piano"
var sample_spacing = 6 # optional param to select a specific resolution library if there are multiple
var note = "D4"
var velocity = 127 # 0-127 
var release = 99999.0

var note_value = -1

func _ready():
	if note_value == -1:
		note_value = note_str_to_int(note)
	else:
		note = note_int_to_str(note_value)
		
	var instruments = DirAccess.get_directories_at(INSTRUMENTS_DIRECTORY)
	var instrument_directory : String
	for file in instruments:
		var split = file.split("-")
		if split[0] == instrument and (sample_spacing == 0 or split[1].begins_with(str(sample_spacing))):
			instrument_directory = INSTRUMENTS_DIRECTORY + file + "/"
	
	if instrument_directory:
		var samples = DirAccess.get_files_at(instrument_directory) # array of strings of audio files, ex: ["piano-2s-A6-V90-J6YM.wav", "...]
		var min_dist_note = ""
		var min_dist = 1000
		var min_dist_vel = 1000
		for sample in samples:
			var split = sample.split("-")
			var sample_note_value : int
			var sample_note_velocity : int
			if split[3].begins_with("V"): # checking if the negative sign counted as a split
				sample_note_value = note_str_to_int(split[2])
				sample_note_velocity = int(split[3].split("V")[1])
			else:
				sample_note_value = note_str_to_int(split[2] + "-" + split[3])
				sample_note_velocity = int(split[4].split("V")[1])
				
			# if this is a new low in note distance or velocity
			if (min(abs(sample_note_value - note_value), abs(min_dist)) != abs(min_dist)) or (abs(sample_note_value - note_value) == abs(min_dist) and abs(sample_note_velocity - velocity) < abs(min_dist_vel)): 
				min_dist = note_value - sample_note_value
				min_dist_note = sample
				min_dist_vel = velocity - sample_note_velocity
				if min_dist == 0:
					break
					
		
		stream = load(instrument_directory + min_dist_note)
		pitch_scale = pow(2, min_dist / 12.0)
		volume_db = clamp(linear_to_db(float(min_dist_vel) / 127.0 + 1.0), -300.0, 6.0) 
		print("mindistnote: ", min_dist_note, "\nmindistvel:", min_dist_vel, "\npitch:", pitch_scale, "\nvolume:", volume_db)
		play()
		playing = true
		
	else:
		printerr("instrument not found: ", instrument)
		queue_free()
	

var play_time = 0.0
var fade_out = false
func _process(delta: float):
	play_time += delta
	if play_time > release:
		fade_out = true
	
	if fade_out:
		volume_db = clamp(linear_to_db(db_to_linear(volume_db) - FADE_OUT_SPEED * delta), -300.0, 6.0)
		if not clamp(linear_to_db(db_to_linear(volume_db) - FADE_OUT_SPEED * delta), -300.0, 6.0) <= 100:
			volume_db = -80
			queue_free()

			
	
	if not playing:
		queue_free()



func note_str_to_int(note_str : String) -> int:
	var len = note_str.length()
	if len < 2 or len > 4: #making sure the note str is formatted correctly
		printerr("incorrectly formatted note: ", note_str)
		return -1
	
	note_str = note_str.to_upper()
	
	var out : int = 0
	
	out += 24 # add default offset ("C-2" should be 0)
	
	if "-" in note_str: # add octive
		out -= 12 * int(note_str[-1])
	else: 
		out += 12 * int(note_str[-1])
	
	match note_str[0]: # add note offset
		"A": out += 9
		"B": out += 11
		"C": out += 0
		"D": out += 2
		"E": out += 4
		"F": out += 5
		"G": out += 7
	
	if note_str[1] == "#": out += 1
	
	return out

func note_int_to_str(note_int : int) -> String:
	if note_int < 0 or note_int > 127: #making sure the note int is in range
		printerr("incorrectly formatted note: ", note_int)
		return "*"
	
	var octave = floor(note_int / 12) - 2
	var note_letter : String = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"][note_int % 12]
	return note_letter + str(octave)
	
	#match note_int % 12: # add note offset
		#0: note_letter = "C"
		#1: note_letter = "C#"
		#2: note_letter = "D"
		#3: note_letter = "D#"
		#4: note_letter = "E"
		#5: note_letter = "F"
		#6: note_letter = "F#"
		#7: note_letter = "G"
		#8: note_letter = "G#"
		#9: note_letter = "A"
		#10: note_letter = "A#"
		#11: note_letter = "B"
	
	
