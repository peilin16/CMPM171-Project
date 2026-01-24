extends Resource
class_name Cast_parser

var parent_controller

func _init(p) -> void:
	parent_controller = p

func build_orders_from_step(step) -> Order:
	if typeof(step) != TYPE_DICTIONARY:
		push_warning("Caster step must be Dictionary, got: " + str(step))
		return Order.new()
	
	var t := str(step.get("type", ""))
	match t:
		"single","shoot one":
			return _make_single_shot_order(step)

		"fan_shape","fan":
			return _make_fan_shape_orders(step)
		"multiple","multi":
			return _make_mutiple_orders(step)
		"random_fan":
			return _make_random_fan_orders(step)

		_:
			push_warning("Unknown caster step type: " + t)
			return ;



#base shooting cfg parameter
func _set_up_base(cfg: Shoot_configure, step: Dictionary) -> void:
	if step.has("refer_bullet"):
		cfg.refer_bullet = step.get("refer_bullet");
	var color := str(step.get("color", "BLUE"))
	match color:
		"RED": cfg.color = Shoot_configure.ColorType.RED
		"RANDOM": cfg.color = Shoot_configure.ColorType.RANDOM
		_: cfg.color = Shoot_configure.ColorType.BLUE
	cfg.color_random_seed_index = int(step.get("color_seed", 0));
	cfg.pool_name = str(step.get("pool", "MEDIUM_ROUND_BULLET"))
	cfg.damage = int(step.get("damage", 5))
	cfg.color_random_seed_index = int(step.get("color_seed", 0))
	cfg.controller = parent_controller;




func _apply_aim(cfg: Shoot_configure, step: Dictionary) -> void:
	var aim := str(step.get("aim", "ANGLE"))
	cfg.origin = step.get("origin", null);
	if cfg.origin == null:
		cfg.origin = parent_controller;
		
	if step.has("move_script"):
		cfg.move_script = step.get("move_script");
	match aim:
		"OBJECT":
			cfg.aim_mode = Shoot_configure.AimMode.OBJECT
			cfg.object = step.get("object", null) # 不给就默认玩家
			#if not set_up_move:
				#cfg.move_configure = Target_move_configure.new();
				#
				#cfg.move_configure.is_continue = true;
		"TARGET":
			cfg.aim_mode = Shoot_configure.AimMode.TARGET
			cfg.target = step.get("target", Vector2.ZERO)
		_:
			cfg.aim_mode = Shoot_configure.AimMode.ANGLE
			#cfg.move_configure = Direction_move_configure.new();
			#cfg.move_configure.direction_degree = float(step.get("deg", 0.0))
			cfg.angle =  float(step.get("deg", step.get("angle", step.get("direction", 0.0))));
	cfg.speed = step.get("speed", 120);


func _make_mutiple_orders(step: Dictionary) -> Order:
	var cfg := Multi_shoot_configure.new()
	_set_up_base(cfg, step);
	_apply_aim(cfg, step);
	cfg.interval = float(step.get("interval", 1.3))
	cfg.num = int(step.get("num", 5))
	if step.has("speed_arr"):
		cfg.speed_arr = step.get("speed_arr");
	if step.has("from_speed") and step.has("to_speed") :
		cfg._speed_setting(step.get("from_speed"), step.get("to_speed"));
	if step.has("vfx"):
		_make_shoot_vfx( parent_controller,cfg,step["vfx"])
	return Order.new(cfg);
	
		
func _make_single_shot_order(step: Dictionary) -> Order:
	var cfg := Shoot_configure.new()
	_set_up_base(cfg, step);
	_apply_aim(cfg, step)
	if step.has("vfx"):
		_make_shoot_vfx( parent_controller,cfg,step["vfx"])
	return Order.new(cfg)


func _make_fan_shape_orders(step: Dictionary) -> Order:
	var cfg := Fan_shape_configure.new()
	_set_up_base(cfg, step);

	#cfg.pool_name = str(step.get("pool", "MEDIUM_ROUND_BULLET"))
	#cfg.damage = int(step.get("damage", 5))

	cfg.spread_angle_deg = float(step.get("spread", 30.0))
	cfg.bullet_count = int(step.get("count", 5))
	cfg.shoot_time = int(step.get("time", 1))
	cfg.shoot_interval = float(step.get("interval", 0.2))

	_apply_aim(cfg, step)

	# color
	# vfx
	if step.has("vfx"):
		_make_shoot_vfx( parent_controller,cfg, step["vfx"])

	return Order.new(cfg)

# Caster.gd or Enemy_logic helper
func _make_shoot_vfx(controller, shoot_cfg: Shoot_configure, vfx_dict: Array) -> void:
	if vfx_dict == null or vfx_dict.is_empty():
		return
	for k in vfx_dict:
		match k.get("shoot_mode",k.get("shoot mode")):
			"start":
				shoot_cfg.start_vfx = k
			"shooting":
				shoot_cfg.shooting_vfx= k
			"shoot_one":
				shoot_cfg.shoot_one_vfx= k
			"bullet":
				shoot_cfg.bullet_vfx= k
				
# Caster.gd
# 约定：entry = ["random_fan", params_dict]
func _make_random_fan_orders(step:Dictionary)-> Order:
	var shoot_cfg := Random_fan_shape_configure.new()
	_set_up_base(shoot_cfg, step);


	shoot_cfg.spread_angle_deg = float(step.get("spread", 30.0))
	shoot_cfg.bullet_count = int(step.get("count", 5))
	shoot_cfg.should_have_one_on_base = bool(step.get("base_one", false))
	shoot_cfg.is_overlap = bool(step.get("overlap", false))
	shoot_cfg.fan_seed_index = int(step.get("fan_seed", 1))
	shoot_cfg.shoot_time = int(step.get("time", 1))
	shoot_cfg.shoot_interval = float(step.get("interval", 0.3))


	_apply_aim(shoot_cfg, step);


	return Order.new(shoot_cfg);
