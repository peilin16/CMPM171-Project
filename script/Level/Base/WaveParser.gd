extends Resource
class_name Wave_parser


var _built_wave: Wave;
var parent_controller

func _init(p = null) -> void:
	parent_controller = p

func get_wave()->Wave:
	return _built_wave;

func setup(d: Dictionary) -> Wave:
	_built_wave = null;
	_build_wave_from_dict(d);
	if _built_wave == null:
		_built_wave = Wave.new();
	return _built_wave;
	
	
func _build_wave_from_dict(d: Dictionary) :
	var mode := str(d.get("mode", "wave"))
	match  mode:
		"timer","delay":
			_build_timer_wave(d);
		"enemy","spawn","enemy_spawn":
			_build_enemy_wave(d);
		"shop":
			_build_shop_wave(d);
		"clear":
			_build_clear_wave(d);

func _build_clear_wave(d: Dictionary) -> void:
	_built_wave = Clear_condition_wave.new();
	
func _build_shop_wave(d: Dictionary) -> void:
	_built_wave = Shop_wave.new();

func _apply_base(d: Dictionary) -> void:
	_built_wave._is_ready = false;
	
func _build_timer_wave(d: Dictionary) -> void:
	_built_wave = Timer_wave.new();
	_apply_base(d);
	_built_wave.duration = d.get("delay", d.get("finished", 3.0))
	
func  _build_enemy_wave(d: Dictionary) -> void:
	_built_wave = Enemy_spawn_wave.new();
	_apply_base(d);
	_built_wave.enemy_name = d.get("name", d.get("enemy_name", "GENERIC_FAIRY_1"))
	_built_wave.spawn_count =  d.get("count", d.get("num", 1))
	_built_wave.spawn_interval =  d.get("interval", d.get("spawn_interval", 0))
	#_built_wave.position =  d.get("position", d.get("position", [Vector2.ZERO]));
	var pos = d.get("positions", d.get("position", [Vector2.ZERO]));
	if pos is Vector2:
		_built_wave.positions.add_item(pos)
	else:
		_built_wave.positions.setup(pos);	
	_built_wave.behavior_code =  d.get("behavior", d.get("behavior_code", ""))
	_built_wave.override =  d.get("override", d.get("enemy", null))
