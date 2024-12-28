extends Node

const EPOCH = 101293090 # The Unix timestamp where all music is generated from

const keys : Dictionary = {
	"Major":[],
	"Natural Minor":[],
	"Harmonic Minor":[],
	
	"Whole":[],
	"Pentatonic keys":[]
}




var music_seed = 1


@onready var note_scene = preload("res://note.tscn")
@onready var note_container = $notes


func _ready() -> void:
	var samp = 6
	print(range(0))
	print(int(Time.get_unix_time_from_system() * 1000))
	await get_tree().create_timer(5.0).timeout
	play_note("piano", "G5", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "D4", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "E4", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "F4", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "G4", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "A4", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "B4", 70, samp, 0.2)
	await get_tree().create_timer(0.5).timeout
	play_note("piano", "C5", 70, samp, 0.2)
	await get_tree().create_timer(1.0).timeout
	play_note("piano", "C4", 70, samp)
	play_note("piano", "C3", 70, samp)
	play_note("piano", "C5", 70, samp)





var seeded_rands_called : int = 0
func reset_rand_count():
	seeded_rands_called = 0

func randf_seeded(start : float = 0.0, end : float = 1.0):
	seed(music_seed)
	for i in range(seeded_rands_called):
		randi() 
	return randf_range(start, end)
	seeded_rands_called += 1


func randf_time_seeded(start : float = 0.0, end : float = 1.0):
	seed(music_seed)


func play_note(inst : String, note : String, velocity : int, samples : int = 0, release : float = 99999.0):
	var note_instance = note_scene.instantiate()
	note_instance.instrument = inst
	note_instance.note = note
	note_instance.velocity = velocity
	note_instance.sample_spacing = samples
	note_instance.release = release
	note_container.add_child(note_instance)

func play_int_note(inst : String, note : int, velocity : int, samples : int = 0, release : float = 99999.0):
	var note_instance = note_scene.instantiate()
	note_instance.instrument = inst
	note_instance.note_value = note
	note_instance.velocity = velocity
	note_instance.sample_spacing = samples
	note_instance.release = release
	note_container.add_child(note_instance)

func play_chord(inst : String, note : String, velocity : int, samples : int = 0, release : float = 99999.0):
	pass



