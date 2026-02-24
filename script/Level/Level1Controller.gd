extends Level_controller
class_name Level1_controller


func _ready() -> void:
	level = Level1.new();	
	pause_menu.visible =false;
	
	GameManager.level_manager.setup(self);
	GameManager.player_manager._spawn_player(self,Vector2(-200,0));
	super._ready();
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
	widget_spawner.spawn_widget(Vector2(100,200), 4);
	#_spawn_enemy_for_test("StoneLionBoss", Vector2(220, 0))
	#_spawn_enemy_for_test("Grunt", Vector2(80, -120))
	#_spawn_enemy_for_test("GruntPlus", Vector2(80, 120))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("stop"):
		if not pause_menu.visible:
			pause_menu.visible = true;
		pause_menu.global_position = GameManager.camera_manager.get_center()
		get_tree().paused = true;
	

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
