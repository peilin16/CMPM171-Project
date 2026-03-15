extends Node
class_name LevelManager

@export var current_level :Level_controller;
@export var level_name:String
@onready var _current_level_index:int = 0;
var _auto_start_next_level: bool = false


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#current_level_index = 0;



func setup(level:Level_controller)->void:
	current_level = level; 
	level_name = level.level.level_name;
	_current_level_index =_current_level_index + 1;
	
func request_auto_start_next_level() -> void:
	_auto_start_next_level = true

func consume_auto_start_next_level() -> bool:
	var should_auto_start := _auto_start_next_level
	_auto_start_next_level = false
	return should_auto_start

func reset_run_state() -> void:
	_auto_start_next_level = false
	_current_level_index = 1;

func get_level_name()->String:
	return level_name;

func get_level_index()->int:
	return _current_level_index;
