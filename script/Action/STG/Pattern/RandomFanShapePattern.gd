# RandomFanShapePattern.gd
extends Shooting_pattern
class_name Random_fan_shape_pattern

var _shots_left: int = 0
var _cooldown: float = 0.0
var _rand: Random_single_float = Random_single_float.new()

func _ready(runner: Runner, configure: Configure) -> void:
	shoot_configure = configure as Random_fan_shape_configure;
	
	preload_bullet(configure.pool_name, shoot_configure.shoot_time * shoot_configure.bullet_count);
	super._ready(runner, configure)

	var cfg := shoot_configure as Random_fan_shape_configure
	_shots_left = max(cfg.shoot_time, 1)
	_cooldown = 0.0

	_rand.set_seed_index(shoot_configure.fan_seed_index)
	_rand.setting(1.0,0.0) # returns [0,1)
	
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	#var cfg := configure as Random_fan_shape_configure
	#if cfg == null:
		#return true

	if not start_vfx_bool(delta):
		return false;

	_cooldown -= delta
	if _cooldown > 0.0:
		return false

	_fire_random_fan_once(runner, shoot_configure)

	_shots_left -= 1
	if _shots_left <= 0:
		return true

	_cooldown = max(shoot_configure.shoot_interval, 0.0)
	return false


func _fire_random_fan_once(runner: Runner, cfg: Random_fan_shape_configure) -> void:
	var count :float= max(cfg.bullet_count, 1)
	var spread :float= abs(cfg.spread_angle_deg)
	var base := _compute_base_deg(cfg)
	
	var start_deg := base - spread
	var end_deg := base + spread
	
	var angles: Array[float] = []
	angles.resize(0)
	
	# if must have one on base
	if cfg.should_have_one_on_base and count > 0:
		angles.append(base)

	var remain := count - angles.size()
	if remain > 0:
		var generated := _generate_random_angles(start_deg, end_deg, remain, cfg.is_overlap)
		for a in generated:
			angles.append(a)

	# (optional) sort for nicer look
	angles.sort()

	for deg in angles:
		_shoot_one_by_deg(runner, cfg, deg)


func _generate_random_angles(a: float, b: float, n: int, allow_overlap: bool) -> Array[float]:
	var out: Array[float] = []
	out.resize(0)

	if n <= 0:
		return out

	# If not allow overlap, we use a minimum angular separation heuristic.
	# This is not perfect Poisson-disc, but good enough for bullet patterns.
	var min_sep := 0.0
	if not allow_overlap:
		min_sep = abs(b - a) / max(float(n), 1.0) * 0.5  # tweak factor

	var tries_limit := 30 * n
	var tries := 0

	while out.size() < n and tries < tries_limit:
		tries += 1
		var t := _rand.get_random_float()   # 0~1
		var deg :float= lerp(a, b, t)

		if allow_overlap:
			out.append(deg)
			continue

		var ok := true
		for exist in out:
			if abs(exist - deg) < min_sep:
				ok = false
				break
		if ok:
			out.append(deg)

	# fallback: if couldn't fill due to tight sep, just fill remaining with overlap
	while out.size() < n:
		var t2 := _rand.get_random_float()
		out.append(lerp(a, b, t2))

	return out


func _compute_base_deg(cfg: Shoot_configure) -> float:
	match cfg.aim_mode:
		Shoot_configure.AimMode.ANGLE:
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
	if not shoot_configure.insert_after_base_script and not shoot_configure.move_script.is_empty(): 
		shoot_one(runner)
		return
	var new_script:Array;
	if shoot_configure.block_sec_to_use_custom_script != 0 and not shoot_configure.move_script.is_empty():
		new_script  = [
			{
				"action":"move",
				"type":"direction_linear",
				"angle":deg,
				"speed":cfg.speed,
				#"wave": cfg.wave,
				"sec":shoot_configure.block_sec_to_use_custom_script
			}
		]
		for m in shoot_configure.move_script:
			new_script.append(m);
	else:
		new_script  = [
			{
				"action":"move",
				"type":"direction_linear",
				"angle":deg,
				"speed":cfg.speed,
				#"wave": cfg.wave,
			}
		]

	#cfg.move_configure = mc
	cfg.move_script = new_script;
	#cfg.aim_mode = Shoot_configure.AimMode.ANGLE
	shoot_one(runner)
