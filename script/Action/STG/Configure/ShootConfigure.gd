# shoot_order.gd
extends Configure
class_name Shoot_configure

enum ColorType { BLUE, RED, RANDOM }
enum AimMode { TARGET, ANGLE ,OBJECT}   # 
#enum VFXSlot { START, SHOOTING, SHOOT_ONE, BULLET } #

@export var pool_name: String = "MEDIUM_ROUND_BULLET"
@export var color: ColorType = ColorType.BLUE
@export var aim_mode = AimMode.ANGLE;
@export var damage: int = 5; 
#@export var move_configure:Move_configure;
#@export var move_pattern: Move_pattern;
@export var move_script:Array
@export var color_random_seed_index: int = 0   # what random seed
@export var target:Vector2;
@export var speed:float;
@export var angle:float; # if direction mode
@export var faction:Bullet.Faction;
var refer_bullet:Bullet  #refer bullet if use special bullet data;
var origin;        # from where duck type
var object;			#object controller


#vfx configure
#what vfx use before shooting
var start_vfx: Dictionary #Start_VFX_request;
#what vfx use when shooting
var shooting_vfx:Dictionary# Shoot_VFX_request;
#what vfx use when shoot one
var shoot_one_vfx:Dictionary# Shoot_VFX_request;
#what vfx for bullet configure
var bullet_vfx: Dictionary #VFX_request;

var owner_id: int = -1     # owner id if require abandon value

func _set_base_data(_controller,_origin = null ,_refer_bullet:Bullet = null ):
	origin = _origin;
	controller = _controller
	if origin == null:
		origin = _controller;
	refer_bullet = _refer_bullet;
#setting 2

func _simple_configure_object( speed:float, pool:String, _object, dam:int = 5, _color:ColorType = ColorType.BLUE,_random_seed_index  =0  )->void:
	if pool == "" or pool == null:
		pool_name = "MEDIUM_ROUND_BULLET"
	else:
		pool_name = pool;
	
	damage = dam;
	object = _object;
	color = _color;
	aim_mode = AimMode.OBJECT
	color_random_seed_index = _random_seed_index;

func _simple_configure_direction( speed:float, pool:String, _deg:float,   dam:int = 5 ,_color:ColorType = ColorType.BLUE ,_random_seed_index  =0)->void:
	if pool == "" or pool == null:
		pool_name = "MEDIUM_ROUND_BULLET"
	else:
		pool_name = pool;
	damage = dam;
	#move_configure = Direction_move_configure.new();
	#move_configure.direction_degree = _deg;
	#move_configure.max_velocity = speed;
	color = _color;
	aim_mode = AimMode.ANGLE
	color_random_seed_index = _random_seed_index;
	
	
func _simple_configure_target( speed:float, pool:String, _target:Vector2, dam:int = 5  ,_color:ColorType = ColorType.BLUE,_random_seed_index  =0  )->void:
	if pool == "" or pool == null:
		pool_name = "MEDIUM_ROUND_BULLET"
	else:
		pool_name = pool;
	damage = dam;
	target = _target;
	#move_configure.target = _target;
	#move_configure.max_velocity = speed;
	color = _color;
	aim_mode = AimMode.ANGLE
	color_random_seed_index = _random_seed_index;
	

func default_pattern() ->Pattern:
	return Shooting_pattern.new();
