extends Node

@onready var input : AudioStreamPlayer = $Input
var index : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
var input_threshold := 0.005

@export var output_path :NodePath

func setup_audio(id):
	set_multiplayer_authority(id)
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
	
	playback = get_node(output_path).get_stream_playback()
	
	
func _process(delta):
	if is_multiplayer_authority():
		process_mic()
		
func process_mic():
	var sterio_data : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if sterio_data.size() > 0:
		var data = PackedFloat32Array()
		data.resize(sterio_data.size())
		var max_amplitude := 0.0
		
		# convert to mono
		for i in range(sterio_data.size()):
			var value = (sterio_data[i].x + sterio_data[i].y) / 2
			max_amplitude = max(value, max_amplitude)
			data[i] = value
		
		# checks if person is talking loud enough
		if max_amplitude < input_threshold:
			return
			
		print(data)
			
