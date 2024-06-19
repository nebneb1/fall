extends MeshInstance3D

const FLOAT_HEIGHT = 0.75
const VARIANCE = 2.0
var FLOAT_TIME = 5.0


func _ready():
	randomize()
	FLOAT_TIME += randf_range(-FLOAT_HEIGHT, FLOAT_HEIGHT)
	up()

func up():
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector3(0, FLOAT_HEIGHT, 0), FLOAT_TIME)
	tween.tween_callback(down)

func down():
	var tween := create_tween()
	tween.tween_property(self, "position", position + Vector3(0, -FLOAT_HEIGHT, 0), FLOAT_TIME)
	tween.tween_callback(up)
