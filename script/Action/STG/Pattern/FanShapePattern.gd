# FanShapePattern.gd
extends Shooting_pattern
class_name FanShapePattern

var _shots_left: int = 0
var _cooldown: float = 0.0

func _ready(runner: Runner, configure: Configure) -> void:
	shoot_configure = configure as Fan_shape_configure;
	preload_bullet(configure.pool_name, shoot_configure.shoot_time * shoot_configure.bullet_count);
	_prepare(runner , configure );
	super._ready(runner, configure)

	var cfg := shoot_configure as Fan_shape_configure
	_shots_left = max(cfg.shoot_time, 1)
	_cooldown = 0.0

func play(runner: Runner, configure: Configure, delta: float) -> bool:
	#var cfg := configure as Fan_shape_configure
	#if cfg == null:
		#return true

	# blocking vfx (charge etc.)
	if shoot_configure.start_vfx_configure != null and not shoot_configure.start_vfx_configure.blocking(delta):
		return false

	_cooldown -= delta
	if _cooldown > 0.0:
		return false

	# fire one "fan burst"
	_fire_fan_once(runner, shoot_configure)

	_shots_left -= 1
	if _shots_left <= 0:
		return true

	_cooldown = max(shoot_configure.shoot_interval, 0.0)
	return false


func _fire_fan_once(runner: Runner, cfg: Fan_shape_configure) -> void:
	var count :float= max(cfg.bullet_count, 1)
	var spread :float= abs(cfg.spread_angle_deg)
	var base := _compute_base_deg(cfg)

	if count == 1:
		_shoot_one_by_deg(runner, cfg, base)
		return

	var start_deg := base - spread
	var end_deg := base + spread
	var step := (end_deg - start_deg) / float(count - 1)

	for i in range(count):
		var deg := start_deg + step * float(i)
		_shoot_one_by_deg(runner, cfg, deg)


func _compute_base_deg(cfg: Shoot_configure) -> float:
	# aim_mode decides how to compute base direction
	match cfg.aim_mode:
		Shoot_configure.AimMode.ANGLE:
			# prefer base_angle_deg if exists, otherwise read from move_configure
			if "base_angle_deg" in cfg:
				return cfg.base_angle_deg
			if cfg.move_configure != null:
				return cfg.move_configure.direction_degree
			return 0.0

		Shoot_configure.AimMode.TARGET:
			var from :Vector2= cfg.origin.get_actor_position()
			var to :Vector2= cfg.target
			var dir := (to - from)
			if dir.length() <= 0.001:
				return 0.0
			return rad_to_deg(dir.angle())

		Shoot_configure.AimMode.OBJECT:
			var from2 :Vector2= cfg.origin.get_actor_position()
			var to2 :Vector2= GameManager.player_manager.get_player_position()
			if cfg.object != null:
				to2 = cfg.object.get_actor_position()
			var dir2 := (to2 - from2)
			if dir2.length() <= 0.001:
				return 0.0
			return rad_to_deg(dir2.angle())
	return 0.0


func _shoot_one_by_deg(runner: Runner, cfg: Shoot_configure, deg: float) -> void:
	# IMPORTANT: do NOT permanently mutate cfg.move_configure for other patterns.
	#var saved := cfg.move_configure
	#if cfg.move_script
	# build a clean direction configure for this bullet
	if not shoot_configure.insert_after_base_script and not shoot_configure.move_script.is_empty(): 
		shoot_one(runner)
		return
	var new_script:Array;
	if shoot_configure.block_sec_to_use_custom_script != 0 and not shoot_configure.move_script.is_empty():
		new_script  = [
			{
				"type":"direction_linear",
				"angle":deg,
				"speed":cfg.speed,
				"wave": cfg.wave,
				"sec":shoot_configure.block_sec_to_use_custom_script
			}
		]
		for m in shoot_configure.move_script:
			new_script.append(m);
	else:
		new_script  = [
			{
				"type":"direction_linear",
				"angle":deg,
				"speed":cfg.speed,
				"wave": cfg.wave,
			}
		]

	#cfg.move_configure = mc
	cfg.move_script = new_script;
	#cfg.aim_mode = Shoot_configure.AimMode.ANGLE
	shoot_one(runner)

	#cfg.move_configure = saved
