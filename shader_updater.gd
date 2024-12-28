extends MultiMeshInstance3D

const BASE_RADIUS = 2.0
const SPEED = 0.2
const RETRACT_SPEED = 5.0


var max_durr = 0.0
var chirp_time = 0.0
const MAX_TIME = 0.75
const CHIRP_MULT = 3.0

var targ_radius = BASE_RADIUS

func _process(delta: float):
	material_override.set("shader_parameter/character_position", Global.player.global_position)
	if Global.player.is_chirping:
		max_durr = Global.player.chirp_durr
		targ_radius = clamp(max_durr, 0.0, Global.player.CHIRP_THRESHOLDS[2]) + BASE_RADIUS
		
	elif max_durr != 0.0:
		chirp_time += delta
		targ_radius = clamp(max_durr, 0.0, Global.player.CHIRP_THRESHOLDS[2]) * CHIRP_MULT + BASE_RADIUS
		if chirp_time >= MAX_TIME:
			max_durr = 0.0
			chirp_time = 0.0
	
	else:
		targ_radius = lerp(targ_radius, BASE_RADIUS, delta * RETRACT_SPEED)
	
	if material_override.get("shader_parameter/character_radius") <= targ_radius:
		material_override.set("shader_parameter/character_radius", lerp(material_override.get("shader_parameter/character_radius"), targ_radius, delta * SPEED * (targ_radius-material_override.get("shader_parameter/character_radius"))))
	else:
		material_override.set("shader_parameter/character_radius", lerp(material_override.get("shader_parameter/character_radius"), targ_radius, delta * SPEED * (material_override.get("shader_parameter/character_radius")-targ_radius)))
	
	#if Global.player.is_chirping:
		#max_durr = Global.player.chirp_durr
		#material_override.set("shader_parameter/character_radius", clamp(material_override.get("shader_parameter/character_radius") + max_durr, BASE_RADIUS, BASE_RADIUS*2))
	#elif max_durr != 0.0:
		#chirp_time += delta
		#material_override.set("shader_parameter/character_radius", clamp(material_override.get("shader_parameter/character_radius") + delta * RETURN_SPEED * 2, BASE_RADIUS, BASE_RADIUS*max_durr*CHIRP_MULT))
		#if chirp_time >= MAX_TIME:
			#max_durr = 0.0
			#chirp_time = 0.0
			#
			#
	#elif material_override.get("shader_parameter/character_radius") > BASE_RADIUS:
		#material_override.set("shader_parameter/character_radius", clamp(material_override.get("shader_parameter/character_radius") - delta * RETURN_SPEED, BASE_RADIUS, BASE_RADIUS*10))
	
	
