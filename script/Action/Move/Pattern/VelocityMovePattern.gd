
# Velocity_pattern.gd
extends Move_pattern
class_name Velocity_pattern

@export var accel_pattern1: Acceleration_pattern
@export var accel_pattern2: Acceleration_pattern
@export var linear_pattern: Linear_move_pattern


var v_cfg:Velocity_configure;
var accel1_duration := 0.0;
var current_speed := 0.0

func _init() -> void:
	belong = System.Belong.MOVE
	accel_pattern1 = Acceleration_pattern.new();
	linear_pattern = Linear_move_pattern.new();
	#accel_pattern2 = Acceleration_pattern.new();
func _ready(runner: Runner, configure: Configure) ->void:
	move_runner = runner as Move_runner
	v_cfg = configure as Velocity_configure;
	#if v_cfg.is_target:
		
	
	

	
	#if v_cfg.linear_cfg == null:
		#v_cfg.linear_cfg = Move_configure.new();
		#v_cfg.linear_cfg.speed = v_cfg.accel_cfg1.to_speed;
		#if v_cfg.is_target:
			#v_cfg.linear_cfg.target = v_cfg.target;
		#else:
			#v_cfg.linear_cfg.direction_degree = v_cfg.direction_degree;
	#




	#if v_cfg.linear_cfg:
		#if v_cfg.linear_cfg.speed == 0.0 and v_cfg.accel_cfg1:
			#v_cfg.linear_cfg.speed = v_cfg.accel_cfg1.to_speed
	
	linear_pattern._ready(runner,v_cfg.linear_cfg);

	if v_cfg.accel_cfg1 and v_cfg.accel_cfg1.acceleration != 0.0:
		var dv := v_cfg.accel_cfg1.to_speed - v_cfg.accel_cfg1.from_speed
		accel1_duration = abs(dv) / abs(v_cfg.accel_cfg1.acceleration)
	
	#_prepare_target_move(v_cfg, runner.controller.get_actor_position(), v_cfg.target);
	#v_cfg.accel_cfg1._ready();
	#v_cfg.linear_cfg._ready();
	#if v_cfg.accel_cfg2 == null and v_cfg.dccel:
		#_ensure_decel_cfg(runner, v_cfg, v_cfg.linear_cfg.speed)
		#v_cfg.accel_cfg2.direction_degree = angle_deg;
		#accel_pattern2._ready(runner,v_cfg.accel_cfg2);	
			
	accel_pattern1._ready(runner,v_cfg.accel_cfg1);
	accel_pattern2 = Acceleration_pattern.new();
	if  v_cfg.decel_cfg!= null:
		accel_pattern2._ready(runner, v_cfg.decel_cfg);
func play(runner: Runner, configure: Configure, delta: float) -> bool:

	#if move_runner == null or v_cfg == null:
		#return
	#if move_runner.controller == null:
		#return
	
	# target mode  direction mode
	if v_cfg.is_target and v_cfg.target != Vector2.ZERO:
		return _play_target_velocity(move_runner, v_cfg, delta)
	else:
		return _play_direction_velocity(move_runner, v_cfg, delta)
		
# ------------------------
# target mode
# ------------------------
func _play_direction_velocity(move_runner: Move_runner, v_cfg: Velocity_configure, delta: float) -> bool:
	var t := move_runner.get_elapsed_time();

	# ----  stage 1 acceleration  ----
	if v_cfg.accel_cfg1 and accel_pattern1 and t < accel1_duration:
		accel_pattern1.play(move_runner, v_cfg.accel_cfg1, delta)
		return false

	#var base_speed := 0.0
	#if v_cfg.accel_cfg1:
		#base_speed = v_cfg.accel_cfg1.to_speed

	
	# ---- stage 2 linear ----
	if t >= accel1_duration and t < accel1_duration + v_cfg.constant_time:
		linear_pattern.play(move_runner, v_cfg.linear_cfg, delta)
		return false;

	# ----stage 3 decel ----
	if v_cfg.use_decel and t >= accel1_duration + v_cfg.constant_time:
		#if v_cfg.accel_cfg2 == null:

		accel_pattern2._ready(move_runner , v_cfg.accel_cfg2);
		return accel_pattern2.play(move_runner, v_cfg.accel_cfg2, delta)
		
	return true

# ------------------------
# target mode
# ------------------------
func _play_target_velocity(move_runner: Move_runner, v_cfg: Velocity_configure, delta: float) -> bool:
	var pos = move_runner.controller.get_actor_position()
	#var target := v_cfg.target
	var dist = pos.distance_to(v_cfg.target)
	var decel_distance = accel_pattern2.distance;
	# 0. arrive target
	if dist == 0:
		move_runner.controller.set_actor_position(v_cfg.target)
		return true  

	
	if dist >= decel_distance and not accel_pattern1.play(move_runner, v_cfg.accel_cfg1, delta):
		current_speed = v_cfg.accel_cfg1.current_speed
		return false
	elif dist >= decel_distance and not linear_pattern.play(move_runner, v_cfg.linear_cfg, delta):
		current_speed = v_cfg.linear_cfg.speed
		return false
	elif dist < decel_distance and not accel_pattern2.play(move_runner, v_cfg.accel_cfg1, delta):
		current_speed = v_cfg.accel_cfg2.current_speed
		return false
		
		
		
	#overshoot
	var after_pos = move_runner.controller.get_actor_position()
	var new_dist = after_pos.distance_to(v_cfg.target)
	if new_dist > dist:
		move_runner.controller.set_actor_position(v_cfg.target)
		return true  
#
	#if accel_pattern1 and v_cfg.accel_cfg2:
		#var before_pos = move_runner.controller.get_actor_position()
		#var running3 := accel_pattern2.play(move_runner, v_cfg.accel_cfg2, delta)
		#
#
		## 简单 overshoot 处理：如果减速后反而更远，就拉回 target
		#
#
		## 如果减速 pattern 认为自己结束了（速度到 to_speed），且离 target 很近，就完成
		#if (not running3) and new_dist <= 1.0:
			#move_runner.controller.set_actor_position(v_cfg.target)
			#return false
#
		#return true
		
	return true
	



	#v_cfg.accel_cfg2._ready()
