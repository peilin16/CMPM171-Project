extends Rotate_configure
class_name Relative_rotate_configure

# rotate how many degrees from start (always >= 0)
@export var rotate_deg: float = 0.0




#func reset_runtime() -> void:
	#current_deg = _wrap_deg(start_deg)
	#rotated_deg = 0.0
	#rotate_deg = _wrap_positive_deg(rotate_deg)

func default_pattern()-> Pattern:
	return Relative_rotate_pattern.new();




func _simple_configure_for_target(_controller, _rotate_deg: float, _max_speed: float = 120.0, _clockwise: bool = true,ac:float = -1, dc:float = -1) -> void:
	controller = _controller;
	start_deg = controller.rotate_runner.get_math_deg()
	
	max_speed_deg = abs(_max_speed)
	#use_target = true
	is_clockwise = _clockwise
	rotate_deg = _wrap_positive_deg(_rotate_deg);
	
	#reset_runtime()
	acceleration = ac;
	deceleration = dc;
