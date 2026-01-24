extends Resource
class_name Rotate_parser

var parent_controller

func _init(p) -> void:
	parent_controller = p




func _build_orders_from_step(step) -> Order:
	if typeof(step) != TYPE_DICTIONARY:
		push_warning("Rotate step must be Dictionary, got: " + str(step))
		return null
	
	var t := str(step.get("type",step.get("mode", "")))
	match t:

		"relative","relative_rotate":
			return _make_relative_rotate_order(step)

		"absolute","absolute_rotate":
			return _make_absolute_rotate_order(step)
		"twirl","round":
			return _make_twirl_rotate_order(step)
		_:
			push_warning("Unknown caster step type: " + t)
			return null;

func _set_up_base(cfg: Rotate_configure, step: Dictionary) -> void:
	cfg.start_deg = get_math_deg()#int(step.get("start_deg", step.get("start", 0)));
	cfg.max_speed_deg = float(step.get("speed", step.get("max_speed", step.get("max_speed_deg",100))))
	cfg.acceleration = float(step.get("acceleration", step.get("ac", -1)))
	cfg.deceleration = float(step.get("deceleration", step.get("dc", -1)))
	cfg.is_clockwise = float(step.get("is_clockwise", step.get("clockwise", false)))
	cfg.epsilon_deg = float(step.get("epsilon",0.5))



func get_math_deg() -> float:
	# Godot rotation_degrees: CW+
	# Math: CCW+ => negate
	if parent_controller == null:
		return 0.0
	return fposmod(-parent_controller.rotation_degrees, 360.0)



func _make_relative_rotate_order(step: Dictionary) -> Order:
	var cfg := Relative_rotate_configure.new();
	cfg.rotate_deg = float(step.get("rotate_deg", step.get("deg", 50)));
	_set_up_base(cfg, step);
	return Order.new(cfg)

func _make_absolute_rotate_order(step: Dictionary) -> Order:
	var cfg := Absolute_rotate_configure.new();
	cfg.target_angle = float(step.get("target", step.get("target_angle", 0)));
	_set_up_base(cfg, step);
	return Order.new(cfg)

func _make_twirl_rotate_order(step: Dictionary) -> Order:
	var cfg := Twirl_rotate_configure.new()
	_set_up_base(cfg, step);
	cfg.round_num = int(step.get("round_num", step.get("round_num", 1)));
	cfg.last_turn_angle = float(step.get("target", step.get("target_angle", 0)));
	cfg.is_infinite = bool(step.get("infinite", step.get("is_infinite",false)));
	return Order.new(cfg);
