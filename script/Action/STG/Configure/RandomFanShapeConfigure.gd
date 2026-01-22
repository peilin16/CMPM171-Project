extends Shoot_configure
class_name Random_fan_shape_configure

@export var spread_angle_deg: float = 30.0    # 
@export var bullet_count: int = 5
@export var should_have_one_on_base:bool = false;
@export var fan_seed_index:int;
@export var is_overlap:bool = false;
@export var shoot_time:int = 3; #how many time 
@export var shoot_interval:float = 0.2;#time interval

@export var base_angle_deg: float = 0.0 

# for customer script only 
@export var block_sec_to_use_custom_script:float = 0; 
@export var insert_after_base_script:bool = true

var _random_float:Random_single_float = Random_single_float.new();

func default_pattern() -> Pattern:
	return Random_fan_shape_pattern.new()

func set_fan_shape(spread_angle:float,_bullet_count:int,_should_have_one_on_base:bool = false,_overlap:bool = false,  _shoot_time:int = 1,_shoot_interval:float = 0.3 ,  seed:int = 0):
	spread_angle_deg = spread_angle;
	#base_angle_deg = _base_angle_deg
	should_have_one_on_base = _should_have_one_on_base
	is_overlap = _overlap
	fan_seed_index = seed;
	bullet_count = _bullet_count;
	shoot_time = _shoot_time
	shoot_interval = _shoot_interval
	
