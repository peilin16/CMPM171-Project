extends Node2D
class_name Level_controller

@export var pause_menu:Pause_menu;
@onready var widget_container:Node2D = $WidgetContainer
var level:Level;
func _ready() -> void:
	if level == null:
		level = Level.new();
	print(level.level_name)
	PoolManager.bullet_pool_manager._preload_order(level.bullet_order);
	PoolManager.enemy_pool_manager._preload_order(level.enemy_order);
	PoolManager.bullet_pool_manager._preload_order(level.bullet_order);

func _physics_process(delta: float) -> void:
	pass
