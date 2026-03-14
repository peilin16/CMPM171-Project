extends Node
class_name LevelManager

@export var current_level :Level_controller;
@export var level_name:String
var _auto_start_next_level: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func setup(level:Level_controller)->void:
	current_level = level; 
	#level_name = level.level.level_name;

func request_auto_start_next_level() -> void:
	_auto_start_next_level = true

func consume_auto_start_next_level() -> bool:
	var should_auto_start := _auto_start_next_level
	_auto_start_next_level = false
	return should_auto_start

func reset_run_state() -> void:
	_auto_start_next_level = false

func get_level_name()->String:
	return level_name;
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
