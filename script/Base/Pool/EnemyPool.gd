extends Node

class_name Enemy_pool

@export var preload_count: int = 0
@export var character_scene: PackedScene   
@export var pool_name:= "EnemyPool";
var available_enemies: Array = []
var active_enemies: Array = []



func get_pool_name() -> String:
	return pool_name   # Unique Pool Name


# ---------- preload ----------
func preload_enemies(count: int) -> void:
	for i in range(count):
		var b = _create_enemy()
		_deactivate_enemy(b)
		available_enemies.append(b)

# spawn
func spawn_enemy() -> Node:
	var character_scene: Enemy_controller = null


	if available_enemies.size() > 0:
		character_scene = available_enemies.pop_back()
	else:

		character_scene = _create_enemy()


	if "visible" in character_scene:
		character_scene.visible = true

	#character_scene._character.is_active = true
	#character_scene._character.is_off_screen = false;
	#character_scene.activate();
	active_enemies.append(character_scene)
	return character_scene
		
	
func _create_enemy() -> Node:
	if character_scene == null:
		push_error("enemy pool: character is not assigned!")
		return null
	var character = character_scene.instantiate()
	# connet signal of _enemy
	GameManager.enemy_manager.register_enemy(character);
	if character.has_signal("enemy_deactivated"):
		character.connect("enemy_deactivated", Callable(self, "_on_character_deactivated"));
	preload_count += 1;
	return character

# ---------- deactivated ----------
func _on_enemy_deactivated(character_scene: Node) -> void:
	# remove from active array
	if character_scene in active_enemies:
		active_enemies.erase(character_scene)
	
	if not (character_scene in available_enemies):
		_deactivate_enemy(character_scene)
		available_enemies.append(character_scene)
	character_scene._enemy._init();		
# ---------- singal  deactive ----------
func _deactivate_enemy(character_scene: Node) -> void:
	character_scene._enemy._init();
	character_scene.visible = false
	character_scene._enemy.is_active = false

	if "position" in character_scene:
		character_scene.global_position  =  Vector2(-9999, -9999) # 
	elif "position" in character_scene:
		character_scene.position = Vector2(-9999, -9999);	
		
# ---------- recycle enemy ----------
func _deactivate_all() -> void:
	for b in active_enemies:
		_deactivate_enemy(b)
		if not (b in available_enemies):
			available_enemies.append(b)
	active_enemies.clear()

# ---------- free all scene ----------
func clear() -> void:
	for b in active_enemies:
		ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		GameManager.enemy_manager.unregister_enemy(b);
		b.queue_free()
	for b in available_enemies:
		ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		GameManager.enemy_manager.unregister_enemy(b);
		b.queue_free()
	active_enemies.clear()
	available_enemies.clear()
	
