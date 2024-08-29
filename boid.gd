extends Area3D

const DETECT_RADIUS = 20.0
const SPACE_RADIUS = 10.0
const MAX_DIST = 25.0

const SPEED = 10.0
#const MAX_SPEED = 20.0

var camera : Camera3D
#particles1, particles2, trail quality, trails


var heading = Vector3.ZERO

const ALIGNMENT_STR = 0.04
const COHESION_STR = 1.0
const SEPERATION_STR = 1.0
const CENTER_PULL = 0.1

var rot_axis : Vector3
const ROT_SPEED = -1

#for optimizations
var id := 0
var stall := 0
const DRAW_DIST = [60,90,40,400]
const CALC_DIST = [[8, 200], [4, 60], [2, 30], [1, 0]]

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("chirp"):
		#DETECT_RADIUS = randf_range(5.0, 40.0)
		#SPACE_RADIUS = randf_range(1.0, 20.0)
		#speed = randf_range(1.0, 20.0)
		#ALIGNMENT_STR = randf_range(0.0, 0.1)
		#COHESION_STR = randf_range(0.5, 2.0)
		#SEPERATION_STR = randf_range(0.5, 2.0)
		#CENTER_PULL = randf_range(0.05, 0.2)
		#ROT_SPEED = randf_range(-0.5, -2.0)
		#$CollisionShape3D.shape.radius = DETECT_RADIUS
		#$Close/CollisionShape3D.shape.radius = SPACE_RADIUS
		
		
func _ready() -> void:
	if id == 0: Debug.track(self, "stall", true)
	#Debug.track(self, "heading")
	randomize()
	rot_axis = Vector3(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0),randf_range(-1.0, 1.0)).normalized()
	#speed = randf_range(0.0, 20.0)
	heading = Vector3(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0),randf_range(-1.0, 1.0)).normalized()
	global_position *= Vector3(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0),randf_range(-1.0, 1.0))*2.0
	$CollisionShape3D.shape.radius = DETECT_RADIUS
	$Close/CollisionShape3D.shape.radius = SPACE_RADIUS

func _process(delta: float):
	if camera:
		var dist = global_position.distance_to(camera.global_position)
		for threshold in CALC_DIST:
			if dist < threshold[1] and id % threshold[0] == stall % threshold[0]:
				#print("a")
				$trail/sparkles.emitting = dist < DRAW_DIST[0]
				$trail/sparkles2.emitting = dist < DRAW_DIST[1]
				if dist < DRAW_DIST[2]:
					pass
					#$trail.mesh.radial_segments = 4
					#$trail.mesh.rings = 1
				else:
					$trail.mesh.radial_segments = 7
					$trail.mesh.rings = 5
				$trail.emitting = dist < DRAW_DIST[3]
				update_heading(delta, threshold[0])
				if abs(stall) > 10000: stall = 0
				break
	else:
		update_heading(delta)
	
	stall += 1
	global_position += heading.normalized() * SPEED * delta
	
	

func update_heading(delta : float, multiplier : float = 1.0):
	var neighbors = get_overlapping_areas()
	var close_neighbors = $Close.get_overlapping_areas()
	if neighbors.size() != 0:
		var headings := Vector3.ZERO
		var positions_far := Vector3.ZERO
		var positions_close := Vector3.ZERO
		#var speeds := 0.0
		for neighbor in neighbors:
			if not neighbor.is_in_group("close"):
				#print(neighbor.name)
				headings += neighbor.heading
				positions_far += neighbor.global_position
			#speeds += neighbor.speed
				
		
		for neighbor in close_neighbors:
			if neighbor.is_in_group("close"):
				positions_close += neighbor.global_position
			
		# alignment rule
		heading = (heading + headings.normalized() * ALIGNMENT_STR * multiplier).normalized()
		
		#cohesion rule
		heading = (heading + to_local(positions_far / neighbors.size()).normalized() * COHESION_STR * multiplier).normalized()
		
		#seperation rule
		heading = (heading + to_local(positions_close / neighbors.size()).normalized() * SEPERATION_STR * multiplier * -1).normalized()
		
		#stay near the middle
		if global_position.length() > MAX_DIST:
			heading = (heading + global_position.normalized() * -1 * CENTER_PULL * global_position.length()/MAX_DIST)
		
		#match speed (of nearby guys + speed up with more number of guys
		#*100.0/close_neighbors.size()
		#speed = clamp(lerp(speed, (speeds/neighbors.size())+2, delta), 0.0, MAX_SPEED)
		
	heading = heading.normalized().rotated(rot_axis,ROT_SPEED*delta)
	#$Mesh.look_at(heading)
	#$Mesh.rotation.y += PI/
