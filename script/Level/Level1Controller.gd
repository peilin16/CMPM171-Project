extends Level_controller
class_name Level1_controller

@onready var start_menu:Start_menu = $StartMenu
@onready var weather_filter = $WeatherFilter
func _ready() -> void:
	level = Level1.new();	
	pause_menu.visible =false;
	name = "Town";
	#start_menu.visible = true;
	#get_tree().paused = true;
	
	GameManager.level_manager.setup(self);
	
	super._ready();
	await ToolBar.globalDelayCall.delay(0.3)
	shop_menu.visible = false;
	await get_tree().process_frame
	SoundManager.command({
		"sound":"bgm",
		"command":"start",
		"name":"BGM2",
		"fade_in":0.2,
		"fade_out":0.7,
		"transfer_fade_out":0.2,
		"use_loop_segment":true,
		"loop_start_sec":0.3,
		"loop_end_sec":18.0,
		"volume_mul":0.4,
		"pitch_scale":1.0
	});
	
func start_game()->void:
	super.start_game();
	start_menu.visible = false;
	if weather_filter:
		var color_rect = weather_filter.get_node_or_null("ColorRect")
		if color_rect and color_rect.has_method("apply_weather"):
			color_rect.apply_weather()
	SoundManager.command({
		"sound":"bgm",
		"command":"start",
		"name":"BGM2",
		"fade_in":0.2,
		"fade_out":0.7,
		"transfer_fade_out":0.2,
		"use_loop_segment":true,
		"loop_start_sec":0.3,
		"loop_end_sec":18.0,
		"volume_mul":0.4,
		"pitch_scale":1.0
	});

func _spawn_enemy_for_test(pool_name: String, spawn_pos: Vector2) -> void:
	var spawn_director = get_node_or_null("WaveDirector/SubDirector/SpawnDirector")
	if spawn_director and spawn_director.has_method("spawn_enemy"):
		spawn_director.spawn_enemy(pool_name, spawn_pos)
		return

	var pool = PoolManager.enemy_pool_manager.get_pool(pool_name)
	if pool == null:
		return

	var enemy = pool.spawn_enemy()
	if enemy == null:
		return

	var enemy_container = get_node_or_null("EnemyContainer")
	if enemy.get_parent() != null:
		enemy.get_parent().remove_child(enemy)
	if enemy_container:
		enemy_container.add_child(enemy)
	else:
		add_child(enemy)
	enemy.set_actor_position(spawn_pos)
	enemy.activate("")
