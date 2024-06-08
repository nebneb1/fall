extends Node

const BUFFER = 0.5 #seconds
const BUFFER_SIZE := 480 #audio frames
const AUDIO_MIX_RATE = 48000

@onready var input : AudioStreamPlayer = $Input
var index : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
var input_threshold := 0.01
var recieved_buffer := PackedFloat32Array()
var output : AudioStreamPlayer3D
var is_active = false

@export var output_path : NodePath
@export var audio_capture : AudioEffectCapture

var encoder = Opus.new()  
#var decoder = Opus.new()

func setup_audio(id):
	input = $Input
	output = get_node(output_path)
	set_multiplayer_authority(id)
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = audio_capture
	#sync genorator mix rate to heaphone mix rate
	output.stream.mix_rate = AudioServer.get_mix_rate()
	#output.stream.mix_rate = 48000
	output.stream.buffer_length = BUFFER
	output.play()
	playback = output.get_stream_playback()
	

#func _ready():
	#setup_audio(1)


#var mic_sample_rate
#var running_avg : Array = []
func _process(delta):
	#mic_sample_rate = find_sample_rate(delta)
	#if mic_sample_rate:
		#running_avg.append(mic_sample_rate)
	#print(average(running_avg)/2.0)
	if is_active:
		if is_multiplayer_authority():
			process_mic()
			
		#process_voice()

#func average(TheRecentStockMarketFiasco):
	#var total = 0.0
	#for x in TheRecentStockMarketFiasco:
		#total += x
	#total /= TheRecentStockMarketFiasco.size()
	#return total
#
#var prev_num_samples = 0
#func find_sample_rate(delta):
	#var stereo_data : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	#if prev_num_samples == 0:
		#prev_num_samples = stereo_data.size()
		#return null
	#
	#return stereo_data.size() / delta



func process_mic():
	#var stereo_data : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if effect.can_get_buffer(BUFFER_SIZE):
		var stereo_data : PackedVector2Array = effect.get_buffer(BUFFER_SIZE)
		#var data = PackedFloat32Array()
		#data.resize(stereo_data.size())
		#var max_amplitude := 0.0
		#
		## convert to mono
		#for i in range(stereo_data.size()):
			#var value = (stereo_data[i].x + stereo_data[i].y) / 2
			#max_amplitude = max(value, max_amplitude)
			#data[i] = value
		#
		## checks if person is talking loud enough
		#if max_amplitude < input_threshold:
			#return
		
		
		
		var out = encoder.encode(stereo_data)
		
		send_data.rpc(out)
		#send_data(data)

#func process_voice():
	#if recieved_buffer.size() <= 0:
		#return
	#
	##if playback.can_push_buffer(recieved_buffer.size()):
	#for i in range(min(playback.get_frames_available(), recieved_buffer.size())):
		#playback.push_frame(Vector2(recieved_buffer[0], recieved_buffer[0]))
		#recieved_buffer.remove_at(0)
		
	

@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedFloat32Array):
	encoder.decode_and_play(playback, stretch_array(data, (AudioServer.get_mix_rate()/AUDIO_MIX_RATE)*data.size()))
	#recieved_buffer.append_array(data)

func stretch_array(original_array, new_length):
	var stretched_array = []
	var original_length = original_array.size()
	var scale = float(original_length) / float(new_length)
	for i in range(new_length):
		var original_pos = int(i * scale)
		stretched_array.append(original_array[original_pos])
	return stretched_array
