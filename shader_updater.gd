extends MultiMeshInstance3D
var pos = material_override.get("shader_parameter/character_position")


func _process(delta: float):
	print(pos)
	pos = Global.player.global_position
	
