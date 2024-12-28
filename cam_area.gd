extends Area3D
enum Pos {
	LEFT_ADJUSTED,
	RIGHT_ADJUSTED,
	CENTER
}
@export var rot: Vector2 = Vector2.ZERO
@export var ease_type : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var trans_type : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var trans_time = 2.0

@export var cam_pos : Pos = Pos.LEFT_ADJUSTED
@export var zoom : float = 0.0

@export var pull : float = 6.0
@export var deadzone : float = 3.0


