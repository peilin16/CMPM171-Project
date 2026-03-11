# Wave_director.gd
extends Node2D
class_name Wave_director

@onready var sub_director: Sub_director = $SubDirector

var current_wave: Wave
var waves: Array[Wave] = []
var is_run: bool = false
var parser:Wave_parser = Wave_parser.new(self);

var next_level_scenes:String;

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
		get_tree().change_scene_to_file(next_level_scenes);
