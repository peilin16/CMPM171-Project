extends Shoot_configure
class_name Fan_shape_configure


@export var spread_angle_deg: float = 30.0    # 
@export var base_angle_deg: float = 0.0       # 
@export var bullet_count: int = 5 #bullet count for each fan
@export var shoot_time:int = 3; #how many time 
@export var shoot_interval:float = 0.2;#time interval

# for customer script only 
@export var block_sec_to_use_custom_script:float = 0; 
@export var insert_after_base_script:bool = true

func default_pattern() ->Pattern:
	return FanShapePattern.new();

func set_fan_shape(spread_angle:float,_bullet_count:int,_shoot_time:int = 1,_shoot_interval:float = 0.3):
	spread_angle_deg = spread_angle;
	#base_angle_deg = _base_angle_deg
	bullet_count = _bullet_count;
	shoot_time = _shoot_time
	shoot_interval = _shoot_interval
