extends Resource
class_name Level
@export var level_name: String = "level";
@export var level_id: int = 0;
#order
@export var bullet_order = {};
@export var enemy_order = {};
@export var vfx_order ={};
#@export var waves:Array[Wave] = [];

func _init() -> void:
	pass
func _end() -> void:
	pass
