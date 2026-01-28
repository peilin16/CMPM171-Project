# MoveRunner.gd
extends Runner
class_name Move_runner

var current_pattern: Move_pattern
var current_cfg: Move_configure

#var is_running: bool = false
#var is_finished: bool = true
var elapsed_time: float = 0.0
var move_data:Move_data;


func start(actor ,pattern: Pattern, configure: Configure) -> void:
	controller = actor
	stop() # interrupt old
	move_data = Move_data.new();
	if pattern == null or configure == null or controller == null:
		return

	current_pattern = pattern
	current_cfg = configure
	elapsed_time = 0.0
	is_running = true
	is_finished = false

	# auto start position
	if current_cfg.start == Vector2.ZERO:
		current_cfg.start = controller.get_actor_position()
	move_data.reset(controller.get_actor_position())
	current_pattern._ready(self, current_cfg)
	
func stop() -> void:
	if is_running and current_pattern:
		current_pattern.interrupt()
		current_pattern.deactivate()
	is_running = false
	is_finished = true

func _physics_process(delta: float) -> void:
	move_data.record_motion(controller.get_actor_position(),delta);
	if not is_running or is_finished:
		return
	if current_pattern == null or current_cfg == null or controller == null:
		stop()
		return

	elapsed_time += delta
	is_finished = current_pattern.play(self, current_cfg, delta)

	if is_finished:
		current_pattern.deactivate()
		is_running = false

		
func get_data()->Data:
	if move_data:
		return move_data;
	else:
		return Move_data.new();

#for order system only
func get_actor_position() -> Vector2:
	return controller.global_position

func set_actor_position(p: Vector2) -> void:
	controller.global_position = p
