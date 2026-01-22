# DirectionMoveConfigure.gd
extends Move_configure
class_name Direction_move_configure

@export var direction_degree: float = 0.0
@export var move_sec: float = 999999.0  # time-limited direction move

func setup(controller, deg: float, speed: float = 120.0, sec: float = 999999.0, ac: float = -1.0, dc: float = -1.0, _wave: float = 0.0) -> void:
	start = controller.get_actor_position()
	direction_degree = deg
	max_velocity = speed
	move_sec = sec
	acceleration = ac
	deceleration = dc
	wave = _wave
