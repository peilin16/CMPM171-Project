# TargetMoveConfigure.gd
extends Move_configure
class_name Target_move_configure

@export var target: Vector2 = Vector2.ZERO
@export var is_continue: bool = false  # reach target then keep moving along last dir?
@export var arrive_epsilon: float = 1.0
# helper
func setup(controller, _target: Vector2, speed: float = 120.0, ac: float = -1.0, dc: float = -1.0, cont: bool = false, _wave: float = 0.0) -> void:
	start = controller.get_actor_position()
	target = _target
	max_velocity = speed
	acceleration = ac
	deceleration = dc
	is_continue = cont
	wave = _wave
