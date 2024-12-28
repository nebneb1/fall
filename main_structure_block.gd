extends RigidBody3D

@export var target : MeshInstance3D

var speed = 0.5
var targ_pos : Vector3

var targ_rot : Vector3

var targ_basis : Basis
const GRAVITY = 0.25

func _ready():
	move()

func move():
	pass
	

func movee():
	Global.camera_holder.manual_only = false
	Global.camera_holder.set_cam_params(Vector2(0.2, 0.0), Tween.EaseType.EASE_IN_OUT, Tween.TransitionType.TRANS_CUBIC, 6.0, Global.Pos.CENTER, 0.5, 20.0, 3.0)
	if target:
		targ_basis = target.global_basis
		targ_pos = target.global_position
		targ_rot = target.global_rotation

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if targ_pos and targ_rot:
		targ_basis = target.global_basis
		targ_pos = target.global_position
		targ_rot = target.global_rotation
		physics_material_override.friction = 0.1
		linear_velocity = (targ_pos-global_position)*speed
		angular_velocity = calc_angular_velocity(global_basis, targ_basis)
		#add_constant_force(Vector3(0,GRAVITY,0))

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("move"):
		#move()

func calc_angular_velocity(from_basis: Basis, to_basis: Basis) -> Vector3:
	var q1 = from_basis.get_rotation_quaternion()
	var q2 = to_basis.get_rotation_quaternion()

	# Quaternion that transforms q1 into q2
	var qt = q2 * q1.inverse()

	# Angle from quaternion
	var angle = 2 * acos(qt.w)

	# There are two distinct quaternions for any orientation.
	# Ensure we use the representation with the smallest angle.
	if angle > PI:
		qt = -qt
		angle = TAU - angle

	# Prevent divide by zero
	if angle < 0.0001:
		return Vector3.ZERO

	# Axis from quaternion
	var axis = Vector3(qt.x, qt.y, qt.z) / sqrt(1-qt.w*qt.w)

	return axis * angle


func activate():
	Global.camera_holder.manual_only = true
	Global.camera_holder.set_cam_params(Vector2(0.7258, 0.0), Tween.EaseType.EASE_OUT, Tween.TransitionType.TRANS_SINE, 2.0, Global.Pos.CENTER, 0.75, 40.0, 0.0)
	$AnimationPlayer.play("cube")

#func vec3_pow(base : Vector3, exp: float):
	#var out := Vector3.ZERO
	#out.x = pow(base.x, exp)
	#out.y = pow(base.y, exp)
	#out.z = pow(base.z, exp)
	#
	#return out


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "cube":
		Global.can_fall = true
