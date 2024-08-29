extends MeshInstance3D

const SIZE_SCALER = 2.0
const MAX_TIME = 1.5
const SIZE_EFFECT = 0.5 
const MIN_TIME = 0.25

var chirp_size = 1.0

func _ready():
	var tween_scale = create_tween()
	var tween_trans = create_tween()
	scale = Vector3.ZERO
	#tween_scale.finished.connect("tween_scale.finished", Callable(self, "queue_free"))
	tween_scale.tween_property(self, "scale", Vector3.ONE * chirp_size * SIZE_SCALER, chirp_size * MAX_TIME * SIZE_EFFECT + (MAX_TIME - MAX_TIME * SIZE_EFFECT)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	if chirp_size <= 0.2:
		tween_trans.tween_property(self, "mesh:material:shader_parameter/transparency", 0.0, chirp_size * MAX_TIME * SIZE_EFFECT + MIN_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(MAX_TIME - MAX_TIME * SIZE_EFFECT - MIN_TIME)
	else:
		tween_trans.tween_property(self, "mesh:material:shader_parameter/transparency", 0.0, chirp_size * MAX_TIME * SIZE_EFFECT).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_delay(MAX_TIME - MAX_TIME * SIZE_EFFECT)
	await tween_scale.finished
	queue_free()
