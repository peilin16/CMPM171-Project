extends Node2D
class_name Level_controller

@onready var pause_menu:Pause_menu = $PauseMenu;
@onready var shop_menu:Shop_menu = $ShopMenu
@onready var widget_spawner:Node2D = $WidgetSpawner
@onready var director:Wave_director = $WaveDirector
var level:Level;
func _ready() -> void:
	if level == null:
		level = Level.new();
	print(level.level_name)
	PoolManager.bullet_pool_manager._preload_order(level.bullet_order);
	PoolManager.enemy_pool_manager._preload_order(level.enemy_order);
	PoolManager.bullet_pool_manager._preload_order(level.bullet_order);
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("stop"):
		if not pause_menu.visible:
			pause_menu.visible = true;
		pause_menu.global_position = GameManager.camera_manager.get_center()
		get_tree().paused = true;


	
func display_shop()->void:
	shop_menu.global_position = GameManager.camera_manager.get_center()
	shop_menu.visible = true;
	get_tree().paused = true;
	
func undisplay_shop()->void:
	shop_menu.visible = false;
	get_tree().paused = false;
