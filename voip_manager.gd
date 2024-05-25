extends Node

const BUFFER = 6.0 #seconds

@onready var input : AudioStreamPlayer = $Input
var index : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
var input_threshold := 0.005
var recieved_buffer := PackedFloat32Array()
var output : AudioStreamPlayer3D

@export var output_path : NodePath

func setup_audio(id):
	input = $Input
	output = get_node(output_path)
	set_multiplayer_authority(id)
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
		print("inputsetup")
		
	#sync genorator mix rate to heaphone mix rate
	output.stream.mix_rate = AudioServer.get_mix_rate()
	output.stream.buffer_length = BUFFER
	output.play()
	playback = output.get_stream_playback()
	
	
func _process(delta):
	if is_multiplayer_authority():
		process_mic()
		
	process_voice()
		
func process_mic():
	var stereo_data : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if stereo_data.size() > 0:
		var data = PackedFloat32Array()
		data.resize(stereo_data.size())
		var max_amplitude := 0.0
		
		# convert to mono
		for i in range(stereo_data.size()):
			var value = (stereo_data[i].x + stereo_data[i].y) / 2
			max_amplitude = max(value, max_amplitude)
			data[i] = value
		
		# checks if person is talking loud enough
		if max_amplitude < input_threshold:
			return
		
		send_data.rpc(data)
		#send_data(data)
		
	

func process_voice():
	if recieved_buffer.size() <= 0:
		return
	
	for i in range(min(playback.get_frames_available(), recieved_buffer.size())):
		playback.push_frame(Vector2(recieved_buffer[0], recieved_buffer[0]))
		recieved_buffer.remove_at(0)
		
	

@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_data(data : PackedFloat32Array):
	recieved_buffer.append_array(data)
