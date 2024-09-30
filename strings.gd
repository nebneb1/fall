extends MeshInstance3D

const TRANSPARENCY_TRANSSITION_SPEED = 1.0

var points : Array = [Vector3.ZERO, Vector3.ZERO]

const TARGET_SPEED = 3.0
var goal = Vector3.ZERO
var goal_target = Vector3.ZERO

@export var goal_relitive = Vector3.ONE*6
@export var track_to : Node3D 
@export var max_angle_degrees = 30.0
@export var distance : float = 10.0
@export var division_length := 0.1
@export var gravity_effect = -0.2
@export var goal_effect = 0.3

var player_RID : RID
func _ready():
	var count = round(distance / division_length)
	for i in range(count):
		points.append(Vector3(0.0, 0.0, i * division_length))
	
	

func _process(delta: float):
	#get_active_material(0).get("albedo_color").a = lerp(get_active_material(0).get("albedo_color").a, float(Global.player.is_chirping), delta * TRANSPARENCY_TRANSSITION_SPEED)
	#set_instance_shader_parameter("albedo_color", lerp(get_active_material(0).get("albedo_color").a, float(Global.player.is_chirping), delta * TRANSPARENCY_TRANSSITION_SPEED))
	get_active_material(0).albedo_color.a = lerp(get_active_material(0).albedo_color.a, float(Global.player.is_chirping), delta * TRANSPARENCY_TRANSSITION_SPEED)

var player_dir : Vector2
func _physics_process(delta: float):
	
	
	if Global.player:
		player_RID = Global.player.get_rid()
	
	if Global.player.dir.length() != 0:
		player_dir = Global.player.dir
		
	goal_target = goal_relitive
	goal_target = goal_target.rotated(Vector3.UP, -player_dir.angle())
	
	goal = goal.lerp(goal_target, delta * TARGET_SPEED)
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	#var base = Global.player.position + Global.player.get_node("trail").position.rotated(Vector3.UP, Global.player.position)
	var base = to_local(Global.player.get_node("trail").global_position)
	points[0] = base
	
	
	for i in range(1, points.size()):
		var prev_point = points[i]
		points[i] = points[i-1] + (
			(points[i-1].direction_to(points[i]) + (
				Vector3(0.0, gravity_effect, 0.0)
			) + (
				points[i-1].direction_to(track_to.position + goal) * goal_effect 
			)
			).normalized() * division_length)
		if i != 1:
			var vec1 : Vector3 = points[i-2] - points[i-1]
			var vec2 : Vector3 = points[i-1] - points[i]
			var difference = (vec1).angle_to(vec2) - deg_to_rad(max_angle_degrees)
			if difference > 0.0: 
				points[i] = (points[i] - points[i-1]).rotated(vec1.cross(vec2).normalized(), -difference) + points[i-1]
		
		#var pp = PhysicsRayQueryParameters3D.new()
		#pp.to = to_global(points[i])
		#pp.from = to_global(points[i-1])
		#if player_RID:
			#pp.exclude = [player_RID]
		#var collision = get_world_3d().direct_space_state.intersect_ray(pp)
		#if collision:
			#points[i] = prev_point
			#points[i] = points[i-1] + points[i-1].direction_to(points[i]) * division_length
			
		draw_line(points[i-1], points[i])

		
	#draw_line(Vector3.ZERO, base)
	
	mesh.surface_end()


#func reduce_angle():
	#Vector3

func draw_line(from_point : Vector3, to_point : Vector3):
	mesh.surface_add_vertex(from_point)
	mesh.surface_add_vertex(to_point)
	
