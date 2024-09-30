extends FogVolume

@onready var fall_controller = get_parent().get_parent()

func _ready() -> void:
	randomize()
	material.density_texture.noise.seed = randi_range(0, 10000)
	print(material.density_texture.noise.seed)
	#$Area3D.connect("area_exited", Callable(get_parent().get_parent(), "update_fog"))


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		fall_controller.update_fog()
