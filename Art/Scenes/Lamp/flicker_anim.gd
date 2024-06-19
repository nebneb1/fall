extends Node3D
#
const MULTIPLIER = 1.0
const VARIATION = 0.5
const INTERVAL = 0.1
var starting_value : float

func _ready():
	starting_value = $OmniLight3D2.light_intensity_lumens
	flicker()

func flicker():
	var goal = MULTIPLIER + randf_range(MULTIPLIER-VARIATION/2.0, MULTIPLIER+VARIATION)
	var tween = create_tween()
	tween.tween_property($OmniLight3D2, "light_intensity_lumens", starting_value*goal, INTERVAL)
	tween.tween_callback(flicker)
