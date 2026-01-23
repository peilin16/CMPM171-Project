extends Node2D
class_name Movement_scheduler

@onready var task_runner: Task_runner = $TaskRunner

var parent_controller #: Character_controller
var is_running := false
var is_finish := false
var _script: Array = []                 # Array[Dictionary]
var _built_queue: Array[Order] = []     # Array[Order]

# -------------------------
# Duck-type bridge for runners / patterns
# -------------------------
func get_actor_obj() -> Object:
	return parent_controller.get_actor_obj()

func get_actor_position() -> Vector2:
	return parent_controller.global_position

func set_actor_position(p: Vector2) -> void:
	parent_controller.global_position = p

func get_id() -> int:
	return parent_controller.controller_id


# -------------------------
# Lifecycle
# -------------------------
func _ready() -> void:
	parent_controller = get_parent() #as Character_controller
	if parent_controller == null:
		push_warning("Movement_scheduler: parent is not Character_controller")


func setup(script: Array) -> void:
	# script is Array[Dictionary]
	_script = script
	_build_queue_from_script(true)


func start() -> void:
	if _built_queue.is_empty():
		is_finish = true
		is_running = false
		return

	is_finish = false
	is_running = true
	task_runner._start(_built_queue)


func stop() -> void:
	# pause style: stop runner but keep queue
	is_running = false
	if task_runner:
		task_runner.stop()


func cancel() -> void:
	# hard stop + clear runtime state
	is_running = false
	is_finish = true
	if task_runner:
		task_runner.cancel_all()
	clear();


func append(script: Array) -> void:
	for s in script:
		_script.append(s);
		_build_queue_from_script(false);


# task preemption will cancel the current task
func preemption(script: Array)->void:
	if _built_queue.is_empty() and task_runner._current == null:
		setup(script);
	cancel();
	setup(script);
	start();

func get_current_order()->Order:
	return task_runner._current;

func clear() -> void:
	_script.clear()
	_built_queue.clear()
	#current_configure = null

func _physics_process(delta: float) -> void:
	if not is_running:
		return
	#task_runner._physics_process(delta)
	if task_runner.is_done:
		is_running = false
		is_finish = true


## optional: re-run building if you modified _script at runtime
#func rebuild() -> void:
	#_build_queue_from_script()


# -------------------------
# Build queue
# -------------------------
func _build_queue_from_script(is_clear:bool = true) -> void:
	if is_clear:
		_built_queue.clear()
	if _script == null or _script.is_empty():
		return

	for cmd in _script:
		if typeof(cmd) != TYPE_DICTIONARY:
			continue

		var t := str(cmd.get("mode",cmd.get("type", ""))).to_lower()
		match t:
			"timer":
				_built_queue.append(_make_timer_order(cmd))

			# linear direction: move by angle for some seconds
			"direction_linear", "dir_linear", "linear_direction":
				var o := _make_direction_linear_order(cmd)
				if o: _built_queue.append(o)

			# linear target: move toward target (optional continue)
			"target_linear", "linear_target", "linear_to":
				var o2 := _make_target_linear_order(cmd)
				if o2: _built_queue.append(o2)

			# arc target: quadratic bezier (接口先留好)
			"target_arc", "arc", "bezier":
				var o3 := _make_target_arc_order(cmd)
				if o3: _built_queue.append(o3)

			_:
				push_warning("Movement_scheduler: unknown cmd type = %s" % t)


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
