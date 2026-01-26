extends Shooting_pattern
class_name Multi_shoot_pattern


# runtime state
var current_index: int = 0

var started: bool = false
var _timer: float = 0.0;

func _ready(runner: Runner, configure: Configure) -> void:
	if shoot_configure == null:
		shoot_configure = configure as Multi_shoot_configure;
	if shoot_runner == null:
		shoot_runner = runner as Shoot_runner
	current_index = 0
	_timer = 0.0
	started = false
	preload_bullet(configure.pool_name, configure.num);
	_prepare(runner , configure );
	if shoot_configure.speed_arr.is_empty():
		for i in range(shoot_configure.num):
			shoot_configure.speed_arr.push_back(shoot_configure.speed);
	
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	

	#if not _shoot:
		#return false
	if not start_vfx_bool(delta):
		return false;
	# 1) Start immediately on first frame
	if not started:
		shoot_configure.speed = shoot_configure.speed_arr[current_index];
		shoot_one(shoot_runner);
		current_index += 1
		started = true
		return false


	# 2) Wait for interval
	_timer += delta
	if _timer < shoot_configure.interval:
		return false     # still waiting


	# 3) Time to fire next bullet
	_timer = 0.0

	if current_index < shoot_configure.num:
		shoot_configure.speed = shoot_configure.speed_arr[current_index];
		shoot_one(shoot_runner);
		current_index += 1
		return false     # continue pattern

	# 4) All bullets fired → pattern finished
	return true
	
