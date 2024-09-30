extends Node

@export var target : String = "override"
@export var index : int = 0

func _process(delta: float) -> void:
	if target == "override":
		var parent = get_parent()
		parent.get_surface_override_material(index).set("shader_parameter/dissolve_line_start", Global.player.get_node("trail").global_position)
		parent.get_surface_override_material(index).set("shader_parameter/dissolve_line_end", Global.camera_holder.camera.global_position)
