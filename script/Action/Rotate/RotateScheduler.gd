extends Node2D
class_name Rotate_scheduler


@onready var task_runner: Task_runner = $TaskRunner

var controller#: Character_controller
var current_configure = null
var is_running := false
var is_finish := false

var _script: Array = []
var _built_queue: Array[Order] = []

func _ready() -> void:
	controller = get_parent()# as Character_controller
	
func set_up_controller(c)->void:
	controller= c;

func setup(script: Array) -> void:
	_script = script#.duplicate(true)
	_built_queue = _build_queue_from_script(_script)

func start() -> void:
	if _built_queue.is_empty():
		is_finish = true
		is_running = false
		return
	is_finish = false
	is_running = true
	task_runner._start(_built_queue)

func stop() -> void:
	is_running = false
	if task_runner:
		task_runner.stop() 



# task preemption will cancel the current task
func preemption(script: Array)->void:
	if _built_queue.is_empty() and task_runner._current == null:
		setup(script);
	cancel();
	setup(script);
	start();


func get_current_order()->Order:
	return task_runner._current;

func cancel() -> void:
	# 立即结束并清空
	is_running = false
	is_finish = true
	if task_runner:
		task_runner.cancel() # 

func clear() -> void:
	_script.clear()
	_built_queue.clear()
	current_configure = null

func _physics_process(delta: float) -> void:
	if not is_running:
		return
	task_runner._physics_process(delta)
	if task_runner.is_done:
		is_running = false
		is_finish = true

func get_math_deg() -> float:
	# Godot rotation_degrees: CW+
	# Math: CCW+ => negate
	if controller == null:
		return 0.0
	return fposmod(-controller.rotation_degrees, 360.0)



func _build_queue_from_script(script: Array) -> Array[Order]:
	var q: Array[Order] = []
	for step in script:
		var orders := _build_orders_from_step(step)
		for o in orders:
			q.append(o)
	return q


func _build_orders_from_step(step) -> Array[Order]:
	if typeof(step) != TYPE_DICTIONARY:
		push_warning("Rotate step must be Dictionary, got: " + str(step))
		return []
	
	var t := str(step.get("type",step.get("mode", "")))
	match t:
		"timer":
			return [_make_timer_order(step.get("sec", 0.0))]

		"relative","relative_rotate":
			return [_make_relative_rotate_order(step)]

		"absolute","absolute_rotate":
			return [_make_absolute_rotate_order(step)]
		"twirl","round":
			return [_make_twirl_rotate_order(step)]
		_:
			push_warning("Unknown caster step type: " + t)
			return [];

func _set_up_base(cfg: Rotate_configure, step: Dictionary) -> void:
	cfg.start_deg = get_math_deg()#int(step.get("start_deg", step.get("start", 0)));
	cfg.max_speed_deg = float(step.get("speed", step.get("max_speed", step.get("max_speed_deg",100))))
	cfg.acceleration = float(step.get("acceleration", step.get("ac", -1)))
	cfg.deceleration = float(step.get("deceleration", step.get("dc", -1)))
	cfg.is_clockwise = float(step.get("is_clockwise", step.get("clockwise", false)))
	cfg.epsilon_deg = float(step.get("epsilon",0.5))

func _make_timer_order(sec: float) -> Order:
	var o :Timer_order = Timer_order.new(sec);
	return o


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
