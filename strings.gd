extends MeshInstance3D

var points : Array = [Vector3.ZERO, Vector3.ZERO]
var goal = Vector3.ZERO
@export var goal_relitive = Vector3.ONE*6
@export var track_to : Node3D 
@export var max_angle_degrees = 30.0
@export var distance : float = 10.0
@export var division_length := 0.1
@export var gravity_effect = -0.1
@export var goal_effect = 0.2

func _ready():
	var count = round(distance / division_length)
	for i in range(count):
		points.append(Vector3(0.0, 0.0, i * division_length))

var player_dir : Vector2
func _process(delta: float):
	goal = goal_relitive
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	#var base = Global.player.position + Global.player.get_node("trail").position.rotated(Vector3.UP, Global.player.position)
	var base = to_local(Global.player.get_node("trail").global_position)
	points[0] = base
	if Global.player.dir.length() != 0:
		player_dir = Global.player.dir
		
	for i in range(1, points.size()):
		points[i] = points[i-1] + (
			(points[i-1].direction_to(points[i]) + (
				Vector3(0.0, gravity_effect, 0.0)
			) + (
				points[i-1].direction_to(track_to.position + goal.rotated(Vector3.UP, -player_dir.angle())) * goal_effect 
			)
			).normalized() * division_length)
		if i != 1:
			var vec1 : Vector3 = points[i-2] - points[i-1]
			var vec2 : Vector3 = points[i-1] - points[i]
			var difference = (vec1).angle_to(vec2) - deg_to_rad(max_angle_degrees)
			if difference > 0.0:
				points[i] = (points[i] - points[i-1]).rotated(vec1.cross(vec2).normalized(), -difference) + points[i-1]
			
		
		draw_line(points[i-1], points[i])

		
	#draw_line(Vector3.ZERO, base)
	
	mesh.surface_end()


#func reduce_angle():
	#Vector3

func draw_line(from_point : Vector3, to_point : Vector3):
	mesh.surface_add_vertex(from_point)
	mesh.surface_add_vertex(to_point)
	
