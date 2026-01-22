extends Rotate_configure
class_name Twirl_rotate_configure

@export var round_num :int;
@export var last_turn_angle:float;
@export var is_infinite:bool = false;

func _simple_configure_for_target(_controller, _round: int, _max_speed: float = 120.0, _clockwise: bool = true,_last_turn_angle:float = start_deg,  ac:float = -1, dc:float = -1) -> void:
	controller = _controller;
	start_deg = controller.rotate_runner.get_math_deg()
	max_speed_deg = abs(_max_speed)
	round_num = _round
	is_clockwise = _clockwise
	last_turn_angle = _wrap_positive_deg(_last_turn_angle)
	acceleration = ac;
	deceleration = dc;
