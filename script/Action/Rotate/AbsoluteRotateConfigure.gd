extends Rotate_configure
class_name Absolute_rotate_configure

@export var target_angle:float;


func _simple_configure_for_target(_controller, _rotate_target: float, _max_speed: float = 120.0, _clockwise: bool = true,ac:float = -1, dc:float = -1) -> void:
	controller = _controller;
	start_deg = controller.rotate_runner.get_math_deg()
	max_speed_deg = abs(_max_speed)
	#use_target = true
	is_clockwise = _clockwise
	target_angle = _wrap_positive_deg(_rotate_target)
	#reset_runtime()
	acceleration = ac;
	deceleration = dc;

func default_pattern()-> Pattern:
	return Absolute_rotate_pattern.new();
