# Velocity_configure.gd
extends Move_configure
class_name Velocity_configure

# 阶段1：加速配置
@export var accel_cfg1: Acceleration_configure

# 阶段2：匀速配置（只用 speed / direction_degree / wave）
@export var linear_cfg: Move_configure

# 阶段3：减速配置
@export var accel_cfg2: Acceleration_configure

# 是否启用减速阶段
@export var use_decel: bool = true

# dccel = true：
# dccel = false：
@export var dccel: bool = true

# direction 模式下：匀速阶段持续时间（秒）；<=0 表示无限
@export var constant_time: float = 0.0

#@export var linear_speed:float;

# target 模式下：距离目标小于该值时进入减速阶段
@export var decel_distance: float = 0.0;


func _simple_configure_for_target(_start:Vector2,  _target:Vector2, _speed:float = 120,_is_continue :bool = false,_wave:float = 0)->void:
	start = _start;
	is_target = true;
	wave = _wave;
	speed = _speed;
	target = _target;
	accel_cfg1 = Acceleration_configure.new();
	linear_cfg = Move_configure.new();
	var dire = (target - start).normalized()
	var angle_deg =ToolBar.distance_measure.dir_to_angle_deg(dire);
	linear_cfg.direction_degree = angle_deg;
	accel_cfg1.to_speed = _speed;
	#accel_cfg1.direction_degree = _deg
	#linear_cfg.target =_target;
	linear_cfg.speed = accel_cfg1.to_speed
	linear_cfg._ready();
	accel_cfg1._ready();
	#v_cfg.accel_cfg1.target = v_cfg.target;
		#dir = (v_cfg.target - move_runner.controller.get_actor_position()).normalized()
	
	#v_cfg.accel_cfg1.direction_degree = v_cfg.direction_degree;
	
func _simple_configure_for_direction(_start:Vector2, _deg:float, _speed:float = 120, _wave:float = 0)->void:
	start = _start;
	is_target = false;
	wave = _wave;
	speed = _speed;
	direction_degree = _deg
	accel_cfg1 = Acceleration_configure.new();
	linear_cfg = Move_configure.new();
	accel_cfg1.direction_degree = _deg
	linear_cfg.direction_degree = _deg

func _velocity_configure_for_direction(_constant_time: float, _accel_cfg2: Acceleration_configure = null , _dccel:bool= true)->void:
	dccel = _dccel
	if _accel_cfg2 == null and dccel:
		_ensure_decel_cfg();
		accel_cfg2.direction_degree = direction_degree;	
	#accel_pattern2._ready(runner,v_cfg.accel_cfg2);	
	else:
		accel_cfg2 = _accel_cfg2;	
	constant_time = _constant_time

func _velocity_configure_for_target(_accel_cfg2: Acceleration_configure = null , _dccel:bool= true )->void:
	dccel = _dccel
	if _accel_cfg2 == null and dccel:
		_ensure_decel_cfg();
		accel_cfg2.direction_degree = accel_cfg1.direction_degree;	
	#accel_pattern2._ready(runner,v_cfg.accel_cfg2);	
	else:
		accel_cfg2 = _accel_cfg2;	
# ------------------------
# generate decel cfg
# ------------------------
func _ensure_decel_cfg() -> void:
	#v_cfg.accel_cfg2._ready();
	var decel_cfg :=  Acceleration_configure.new();

	decel_cfg.from_speed = speed
	decel_cfg.to_speed = accel_cfg1.from_speed;

	# use -accel1 acceleration
	if accel_cfg1.acceleration != 0.0:
		decel_cfg.acceleration = -abs(accel_cfg1.acceleration)
	elif decel_cfg.acceleration == 0.0:
		# fallback default
		decel_cfg.acceleration = -25.0

	decel_cfg.direction_degree = direction_degree
	decel_cfg.target = target
	
	accel_cfg2 = decel_cfg;

func default_pattern() ->Pattern:
	return Velocity_pattern.new();
