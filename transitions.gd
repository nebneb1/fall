extends Control

const SCENES : Dictionary = {
	"main": preload("res://main.tscn"),
	"fall": preload("res://fall.tscn")
}

# valid types are: fog_fade
func scene(scene : String, type : String, time : float):
	print(type, " to ", scene)
	match type:
		"fog_fade":
			var tween = create_tween()
			tween.tween_property($fog_fade, "color:a", 1.0, time)
			await tween.finished
			get_tree().change_scene_to_packed(SCENES[scene])
			var tween2 = create_tween()
			tween2.tween_property($fog_fade, "color:a", 0.0, time)

func fake_trans(after : Callable, type : String, time : float):
	match type:
		"fog_fade":
			var tween = create_tween()
			tween.tween_property($fog_fade, "color:a", 1.0, time)
			await tween.finished
			after.call()
			var tween2 = create_tween()
			tween2.tween_property($fog_fade, "color:a", 0.0, time)

	
