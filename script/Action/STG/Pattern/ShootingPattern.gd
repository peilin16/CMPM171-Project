extends Pattern
class_name Shooting_pattern
#simple pattern

var shoot_runner :Shoot_runner
var shoot_configure :Shoot_configure
var shooter;
var _shoot = false;
var _bullets: Array = [];
var start_vfx:Shoot_VFX_request;
@export var is_ready:bool = false
# Mutiple_shoot_pattern.gd
var color_int_generator:Random_single_int = Random_single_int.new();


func _init() -> void:
	belong = System.Belong.SHOOT;
	
func _ready(runner: Runner, configure: Configure) ->void:

	if shoot_configure == null:
		shoot_configure = configure as Shoot_configure;
	if shoot_runner == null:
		shoot_runner = runner as Shoot_runner;
	if _bullets.is_empty():
		preload_bullet(configure.pool_name, 1);
	#if not runner.is_ready:
	_prepare(runner , configure );
	_shoot = true;

func _prepare(runner: Runner, configure: Configure)->void:
	shooter = shoot_configure.origin;
	if shoot_configure.color == Shoot_configure.ColorType.RANDOM:
		color_int_generator.set_seed_index(shoot_configure.color_random_seed_index);
		color_int_generator.setting(0,1);
		
	#VFX shooting_vfx_configure
	if not shoot_configure.start_vfx.is_empty():
		start_vfx = shoot_configure.controller.vfx_parser.setup(shoot_configure.start_vfx);
	if not shoot_configure.shooting_vfx.is_empty():
		shooter.vfx_parser.setup(shoot_configure.shooting_vfx);
	
	is_ready = true;
	
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	
	if not shoot_runner.is_running:
		return true
	
		#bullet config
	if start_vfx != null and not start_vfx.blocking(delta):
		return false;
	
	shoot_one(shoot_runner);
	return true;
	
	
#helper function	
func preload_bullet(pool_name:String, num:int ):
	_bullets = PoolManager.bullet_pool_manager.spawns_bullet(pool_name,num);
	
func deactive()->void:
	PoolManager.bullet_pool_manager._deactivate_bullets(shoot_configure.pool_name, _bullets);
	pass


	

# call bullet pool
func shoot_one(runner: Shoot_runner)->void:
	if not shoot_configure.shoot_one_vfx.is_empty():
		shooter.vfx_parser.setup(shoot_configure.shoot_one_vfx);

	var bullet_scene:Bullet_controller = configure_bullet(shoot_configure);
	# Decide bullet color
	bullet_scene.scheduler.clear()# .task_queue.clear();
	bullet_scene.scheduler.setup(configure_move(shoot_configure));
	
	if bullet_scene.get_parent() != shoot_runner.container:
		if bullet_scene.is_inside_tree():
			bullet_scene.get_parent().remove_child(bullet_scene);

	
	bullet_scene.bullet.origin = shooter;
	bullet_scene.bullet.owner_id = shooter.get_id();
	bullet_scene._update_collision();
	
	bullet_scene.activate();
	
func configure_bullet(configure: Shoot_configure ) ->Bullet_controller:
	var bullet_scene:Bullet_controller = _bullets.pop_front();
	shoot_runner.container.add_child(bullet_scene);
	bullet_scene.set_actor_position(shoot_configure.origin.get_actor_position());
	if configure.refer_bullet != null:
		bullet_scene.bullet = configure.refer_bullet.duplicate();
		return bullet_scene;
	
	bullet_scene.bullet.origin = configure.origin;
	
	var bullet_color :Shoot_configure.ColorType = shoot_configure.color;
	if bullet_color == Shoot_configure.ColorType.RANDOM:

		if color_int_generator.get_random_int() == 0:
			bullet_color = Shoot_configure.ColorType.BLUE;
		else:
			bullet_color = Shoot_configure.ColorType.RED;
	if bullet_color==  Shoot_configure.ColorType.BLUE:
		bullet_scene.bullet.current_color = Bullet.BulletColor.BLUE;
		bullet_scene.bullet.is_red = false;
	else:
		bullet_scene.bullet.current_color = Bullet.BulletColor.RED;
		bullet_scene.bullet.is_red = true;
		
	bullet_scene.bullet.is_reflect = false;
	
	bullet_scene.bullet.damage = configure.damage;
	if configure.color == Shoot_configure.ColorType.BLUE:
		bullet_scene.bullet.current_color = Bullet.BulletColor.BLUE;
	elif configure.color == Shoot_configure.ColorType.RED: 
		bullet_scene.bullet.current_color = Bullet.BulletColor.RED;
	#bullet_scene.bullet.move_configure = configure.move_configure;
	bullet_scene.bullet.faction = bullet_scene.bullet.Faction.ENEMY;
	
	return bullet_scene;

func configure_move(configure: Shoot_configure)->Array:
	var origin :Vector2= configure.origin.get_actor_position()
	
	if not configure.move_script.is_empty():
		return configure.move_script;
	var move_script:Array ;
	if configure.aim_mode == Shoot_configure.AimMode.TARGET:
		move_script = [
			{
				"action":"move",
				"mode":"linear_target",
				"target":configure.target,
				"max_velocity":configure.speed,
				"is_continue":true,
			}
		]
	elif configure.aim_mode == Shoot_configure.AimMode.ANGLE:
		move_script = [
			{
				"action":"move",
				"mode":"linear_direction",
				"deg":configure.angle,
				"max_velocity":configure.speed,
				"is_continue":true,
			}
		]
	elif configure.aim_mode == Shoot_configure.AimMode.OBJECT:
		var position:Vector2;
		if configure.object:
			position = configure.object.get_actor_position()
		else:
			position = GameManager.player_manager.get_player_position();
		move_script = [
			{
				"action":"move",
				"mode":"linear_target",
				"target":position,
				"max_velocity":configure.speed,
				"is_continue":true,
			}
		]
		
	return move_script;

	
