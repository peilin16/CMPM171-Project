
extends Move_pattern
class_name Acceleration_pattern
# Acceleration_pattern.gd
var cfg : Acceleration_configure;
var distance:float;
var total_sec:float;

var dir:Vector2;


func _init() -> void:
	belong = System.Belong.MOVE

func _ready(runner: Runner, configure: Configure) ->void:
	move_runner = runner as Move_runner
	cfg = configure as Acceleration_configure
	cfg.current_speed = cfg.from_speed;
	calc_time_and_distance();
	#dir = angle_deg_to_dir(cfg.direction_degree);
	#print(cfg.direction_degree);
	dir = Vector2.RIGHT.rotated(deg_to_rad(cfg.direction_degree)).normalized();
	
	
func calc_time_and_distance() -> void:
	var to_speed = cfg.to_speed;
	var from_speed = cfg.from_speed;
	var dv = to_speed - from_speed  # speed change
	
	# 1. Cannot reach target if acceleration is zero
	if cfg.acceleration == 0:
		push_warning("Acceleration is zero → speed will not change.")
		total_sec = 0.0
		distance = 0.0
		return

	# 2. Check if acceleration direction matches target speed direction
	# dv * a must be positive, otherwise we’re accelerating the wrong way
	if dv * cfg.acceleration <= 0:
		push_warning("Acceleration direction does not lead to target speed.")
		total_sec = 0.0
		distance = 0.0
		return
	# ---- Valid case: uniform acceleration ----
	# t = (vt - v0) / a
	total_sec = dv / cfg.acceleration
	# s = (vt^2 - v0^2) / (2a)
	distance = (to_speed * to_speed - from_speed * from_speed) / (2.0 * cfg.acceleration);
	
	
	
	
#play
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	
	
	cfg.current_speed = cfg.current_speed + cfg.acceleration * delta;
	_record.moved_distance =  cfg.current_speed * delta;
	var finished := false
	if cfg.current_speed == cfg.to_speed and cfg.is_back == false:
		return true;
	# 2）handle speed and go back
	if cfg.to_speed != 0.0:
		if cfg.acceleration > 0.0:
			#：from_speed -> to_speed
			if cfg.current_speed >= cfg.to_speed:
				if cfg.is_back:
					# go back
					var overflow := cfg.current_speed - cfg.to_speed
					cfg.current_speed = cfg.to_speed - overflow
					cfg.acceleration = -cfg.acceleration
				else:
					cfg.current_speed = cfg.to_speed
					finished = true
		elif cfg.acceleration < 0.0:
			# deceleration：from_speed -> to_speed
			if cfg.current_speed <= cfg.to_speed:
				if cfg.is_back:
					var overflow2 := cfg.to_speed - cfg.current_speed
					cfg.current_speed = cfg.to_speed + overflow2
					cfg.acceleration = -cfg.acceleration
				else:
					cfg.current_speed = cfg.to_speed
					finished = true
	else:
		# to_speed == 0 
		if cfg.acceleration < 0.0:
			if cfg.current_speed <= 0.0:
				if cfg.is_back:
					var overflow3 := -cfg.current_speed
					cfg.current_speed = overflow3
					cfg.acceleration = -cfg.acceleration
				else:
					cfg.current_speed = 0.0
					finished = true
		
	if not cfg.is_back and cfg.current_speed < 0.0:
		cfg.current_speed = 0.0
		finished = true

	
	
	print(cfg.direction_degree);
	var pos = runner.controller.get_actor_position()
	pos += dir * cfg.current_speed * delta
	runner.controller.set_actor_position(pos)

	return finished

#if need to change direction, direction mode only
func direction_change(new_deg:float = cfg.direction_degree )->void:
	if new_deg ==  cfg.direction_degree:
		return;
	dir = ToolBar.distanceMeasure.angle_deg_to_dir(new_deg);
