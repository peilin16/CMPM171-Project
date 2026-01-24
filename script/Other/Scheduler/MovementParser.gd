extends Resource
class_name Movement_parser


var parent_controller

func _init(p) -> void:
	parent_controller = p

# -------------------------
# Build queue
# -------------------------
func build_orders_from_step(step: Dictionary) -> Order:

	var t := str(step.get("mode",step.get("type", ""))).to_lower()
	match t:
		# linear direction: move by angle for some seconds
		"direction_linear", "dir_linear", "linear_direction":
			return _make_direction_linear_order(step)

			# linear target: move toward target (optional continue)
		"target_linear", "linear_target", "linear_to":
			return _make_target_linear_order(step)
		"target_arc", "arc", "bezier":
			return _make_target_arc_order(step)
		_:
			push_warning("Movement_scheduler: unknown cmd type = %s" % t)
	return null;

# -------------------------
# Orders factory
# -------------------------
func _make_timer_order(cmd: Dictionary) -> Order:
	var sec := float(cmd.get("sec", 0.0))
	var o := Timer_order.new(sec)
	return o

func _set_up_base(configure:Move_configure ,cmd:Dictionary)->void:
	var speed := float(cmd.get("speed", cmd.get("max_velocity", 120.0)))
	var ac := float(cmd.get("ac", cmd.get("acceleration", -1.0)))
	var dc := float(cmd.get("dc", cmd.get("deceleration", -1.0)))
	var wave := float(cmd.get("wave", 0.0))
	configure.max_velocity = speed
	configure.acceleration = ac
	configure.deceleration = dc
	configure.wave = wave
	configure.start = parent_controller.get_actor_position();
	configure.controller = parent_controller;



func _make_direction_linear_order(cmd: Dictionary) -> Order:
	# required-ish: deg, sec
	var deg := float(cmd.get("deg", cmd.get("angle", cmd.get("direction", 0.0))))
	var sec := float(cmd.get("sec", cmd.get("move_sec", 9999999)))
	# build configure
	var cfg := Direction_move_configure.new();
	
	_set_up_base(cfg,cmd);
	
	
	# 你现在的 Direction_move_configure 有 move_sec
	
	cfg.direction_degree = deg
	cfg.move_sec = sec
	
	return Order.new(cfg)


func _make_target_linear_order(cmd: Dictionary) -> Order:
	var target: Vector2 = cmd.get("target", Vector2.ZERO)
	if target == Vector2.ZERO and cmd.has("x") and cmd.has("y"):
		target = Vector2(float(cmd["x"]), float(cmd["y"]))

	var cont := bool(cmd.get("continue", cmd.get("is_continue", false)))
	var eps := float(cmd.get("eps", cmd.get("arrive_epsilon", 1.0)))

	var cfg := Target_move_configure.new()
	_set_up_base(cfg,cmd);
	cfg.start = parent_controller.get_actor_position()
	cfg.target = target

	cfg.is_continue = cont
	cfg.arrive_epsilon = eps


	return Order.new(cfg);


func _make_target_arc_order(cmd: Dictionary) -> Order:
	# cmd fields:
	# target: Vector2
	# vertex: Vector2 (optional, ZERO -> auto)
	# speed / ac / dc / wave / continue

	var target: Vector2 = cmd.get("target", Vector2.ZERO)
	var vertex: Vector2 = cmd.get("vertex", Vector2.ZERO)

	var cont := bool(cmd.get("continue", cmd.get("is_continue", false)))
	var eps := float(cmd.get("eps", cmd.get("arrive_epsilon", 1.0)))

	var cfg := Arc_move_configure.new()
	_set_up_base(cfg, cmd);
	cfg.target = target
	cfg.vertex = vertex
	cfg.is_continue = cont
	cfg.arrive_epsilon = eps


	return Order.new(cfg)
