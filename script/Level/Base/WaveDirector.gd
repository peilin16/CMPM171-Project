# Wave_director.gd
extends Node2D
class_name Wave_director

@onready var sub_director: Sub_director = $SubDirector

var current_wave: Wave
var waves: Array[Wave] = []
var is_run: bool = false
var parser:Wave_parser = Wave_parser.new(self);

var next_level_scenes:String;

static var global_wave_num: int = 0
const WAVES_PER_LEVEL: int = 3

static func reset_global_progress() -> void:
	global_wave_num = 0

func _ready() -> void:
	next_level_scenes = "";
	


# 一次性预加载所有 wave（比如关卡开始时）
func _preload_waves(arr: Array[Wave]) -> void:
	waves.clear()
	for w in arr:
		if w != null:
			waves.append(w)


func _append_wave(w: Wave) -> void:
	if w == null:
		return
	waves.append(w)


func start() -> void:
	waves.clear()
	current_wave = null
	config_waves();
	if waves.is_empty():
		return

	is_run = true
	_next()


func _physics_process(delta: float) -> void:
	if not is_run :
		return

	if current_wave == null and waves.is_empty():
		return;

	current_wave.update(sub_director, delta)
	if current_wave.is_done(sub_director):
		current_wave.end(sub_director)
		_next()


func _next() -> void:
	if waves.is_empty():
		is_run = false
		current_wave = null
		_next_level();
		return

	current_wave = waves.pop_front()
	if current_wave != null:
		current_wave.start(sub_director)


# skip current wave
func skip() -> void:
	if current_wave != null:
		current_wave.end(sub_director)
	_next()


#wave config
func config_waves() -> void:
	#overwrite
	pass

func set_up_config() ->void:
	pass

func create_wave_from_config(config: Array) -> void:
	for w in config:
		var wave:= parser.setup(w);
		#wave.wave_director = self;
		waves.append(wave);

func _next_level()->void:
	if next_level_scenes != "":
		get_tree().paused = false
		if GameManager.player_manager:
			GameManager.player_manager.save_current_player_state()
		if GameManager.level_manager:
			GameManager.level_manager.request_auto_start_next_level()
		get_tree().change_scene_to_file(next_level_scenes);

# --- Infinite wave generation helpers ---
func _generate_infinite_waves() -> void:
	var config: Array = []
	for i in range(WAVES_PER_LEVEL):
		_append_wave_config(config, Wave_director.global_wave_num, true)
		Wave_director.global_wave_num += 1
	create_wave_from_config(config)

func _append_wave_config(config: Array, wave_num: int, include_shop: bool = true) -> void:
	var enemy_count: int = 6 + wave_num * 2

	config.append({"mode": "timer", "delay": 1.0})

	# GruntPlus ratio: 0% at wave 0-2, ramps to 100% by wave 10
	var grunt_plus_ratio: float = clampf(float(wave_num - 2) / 8.0, 0.0, 1.0)
	var grunt_plus_count: int = int(enemy_count * grunt_plus_ratio)
	var grunt_count: int = enemy_count - grunt_plus_count

	if grunt_count > 0:
		config.append(_make_spawn("Grunt", grunt_count))
		if grunt_plus_count > 0:
			config.append({"mode": "timer", "delay": 3.0})

	if grunt_plus_count > 0:
		config.append(_make_spawn("GruntPlus", grunt_plus_count))

	# Boss appears from wave 5 onward, count increases every 6 waves
	if wave_num >= 5:
		config.append({"mode": "timer", "delay": 5.0})
		var boss_count: int = 1 + (wave_num - 5) / 6
		config.append(_make_spawn("StoneLionBoss", boss_count, [3]))

	config.append({"mode": "clear"})
	if include_shop:
		config.append({"mode": "shop"})
	config.append({"mode": "timer", "delay": 1.0})

func _make_spawn(p_enemy_name: String, count: int, positions: Array = [0, 1, 2, 3, 4]) -> Dictionary:
	return {
		"mode": "enemy_spawn",
		"type": "group",
		"name": p_enemy_name,
		"count": count,
		"behavior": "---",
		"positions": positions,
	}
