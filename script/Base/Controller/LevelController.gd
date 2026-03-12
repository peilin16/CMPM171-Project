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

	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("stop"):
		if not pause_menu.visible:
			pause_menu.visible = true;
		pause_menu.global_position = GameManager.camera_manager.get_center()
		get_tree().paused = true;

func start_game()->void:
	GameManager.player_manager._spawn_player(self,Vector2(0,0));
	director.start();
	PoolManager.bullet_pool_manager._preload_order(level.bullet_order);
	PoolManager.enemy_pool_manager._preload_order(level.enemy_order);
	PoolManager.bullet_pool_manager._preload_order(level.bullet_order);
	
func display_shop()->void:
	if not is_instance_valid(shop_menu):
		shop_menu = get_node_or_null("ShopMenu") as Shop_menu
	if shop_menu == null:
		return
	if shop_menu.has_method("setup_shop"):
		shop_menu.setup_shop()
	shop_menu.global_position = GameManager.camera_manager.get_center()
	shop_menu.visible = true;
	get_tree().paused = true;


func undisplay_shop()->void:
	if is_instance_valid(shop_menu):
		shop_menu.visible = false;
	get_tree().paused = false;

func _exit_tree() -> void:
	PoolManager.widget_pool_manager.clear_all();
	PoolManager.bullet_pool_manager.clear_all();
	PoolManager.enemy_pool_manager.clear_all();
