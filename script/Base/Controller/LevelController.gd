extends Node2D
class_name Level_controller

var _level:Level;
func _ready() -> void:
	if _level == null:
		_level = Level.new();
	print(_level.level_name)
	PoolManager.bullet_pool_manager._preload_order(_level.bullet_order);
	PoolManager.enemy_pool_manager._preload_order(_level.enemy_order);
	#Game_Manager.._preload_order(level.bullet_order);
func _physics_process(delta: float) -> void:
	pass
