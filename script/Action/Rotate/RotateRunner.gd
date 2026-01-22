# Rotate_runner.gd
# Rotate_runner.gd
extends Runner
class_name Rotate_runner

var current_pattern: Rotate_pattern = null
var current_configure: Rotate_configure = null
#var running: bool = false

func _ready() -> void:
	super._ready();
	controller = get_parent()
	

func start(actor, pattern: Pattern, configure: Configure) -> void:
	current_pattern = pattern as Rotate_pattern
	current_configure = configure as Rotate_configure
	#if current_configure:
		#current_configure.reset_runtime()
	is_running = (current_pattern != null and current_configure != null)
	current_pattern._ready(self, configure);

#overload start func and it remove pattern parameter
func activate(actor, configure: Configure)-> void:
	current_pattern = configure.default_pattern() as Rotate_pattern;
	current_configure = configure as Rotate_configure
	#if current_configure:
		#current_configure.reset_runtime()
	is_running = (current_pattern != null and current_configure != null)
	current_pattern._ready(self, configure);


func stop() -> void:
	is_running = false

func _physics_process(delta: float) -> void:
	if not is_running:
		return
	if current_pattern == null or current_configure == null:
		is_running = false
		return
	var keep := current_pattern.play(self, current_configure, delta)
	if not keep:
		is_running = false

func end() ->void:
	is_finished = true;
# -----------------------
# math deg helpers
# -----------------------
func get_math_deg() -> float:
	# Godot rotation_degrees: CW+
	# Math: CCW+ => negate
	if controller == null:
		return 0.0
	return fposmod(-controller.rotation_degrees, 360.0)

func apply_math_deg(math_deg: float) -> void:
	if controller == null:
		return
	controller.rotation_degrees = -wrapf(math_deg, 0.0, 360.0)
