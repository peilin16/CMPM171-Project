# Wave_director.gd
extends Node2D
class_name Wave_director

@onready var sub_director: Sub_director = $SubDirector

var current_wave: Wave
var waves: Array[Wave] = []
var is_run: bool = false
var parser:Wave_parser = Wave_parser.new(self);


func _ready() -> void:
	pass
	
	
# 一次性预加载所有 wave（比如关卡开始时）
func _preload_waves(arr: Array[Wave]) -> void:
	waves.clear()
	for w in arr:
		if w != null:
			waves.append(w)


# 中途追加一波（比如中间插入 Boss 波）
func _append_wave(w: Wave) -> void:
	if w == null:
		return
	waves.append(w)


func start() -> void:
	if waves.is_empty():
		return

	is_run = true
	_next()


func _physics_process(delta: float) -> void:
	if not is_run or waves.is_empty():
		return

	if current_wave == null:
		return

	current_wave.update(sub_director, delta)
	if current_wave.is_done(sub_director):
		current_wave.end(sub_director)
		_next()


func _next() -> void:
	if waves.is_empty():
		is_run = false
		current_wave = null
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
		wave.wave_director = self;
		waves.append(wave);
