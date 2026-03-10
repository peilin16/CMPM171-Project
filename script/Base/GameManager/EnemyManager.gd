extends Node
# EnemyManager.gd
class_name EnemyManager

var _enemies: Dictionary = {}  # {id: EnemyController}
var _active_enemies: Dictionary = {}  # {id: EnemyController}
var _enemy_stats_data: Dictionary = {}

func _ready() -> void:
	_load_enemy_stats()

func _load_enemy_stats() -> void:
	var path = "res://assets/data/enemy_stats.json"
	if not FileAccess.file_exists(path):
		printerr("Enemy stats file found at: ", path)
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		_enemy_stats_data = json.data
		print("Loaded enemy stats for: ", _enemy_stats_data.keys())
	else:
		printerr("JSON Parse Error: ", json.get_error_message())

func get_enemy_stats(enemy_name: String) -> Dictionary:
	if _enemy_stats_data.has(enemy_name):
		return _enemy_stats_data[enemy_name]
	printerr("No stats found for enemy: ", enemy_name)
	return {}

func register_enemy(e: Enemy_controller) -> int:
	var id = ToolBar.gameIDGenerator.generate_id()
	_enemies[id] = e
	e.controller_id = id   # 把 id 回写给敌人本身
	print("Enemy registered:", id, e)
	return id

func unregister_enemy(e: Enemy_controller) -> void:
	if e == null:
		return
	# also remove from active table if present
	for active_id in _active_enemies.keys():
		if _active_enemies[active_id] == e:
			_active_enemies.erase(active_id)
			break
	# unregister enemy
	for id in _enemies.keys():
		if _enemies[id] == e:
			_enemies.erase(id)
			ToolBar.gameIDGenerator.recycle_id(id)
			print("Enemy unregistered:", id)
			return

func get_enemy_by_id(id: int) -> Enemy_controller:
	if _enemies.has(id):
		return _enemies[id]
	return null

func get_all_enemies() -> Dictionary:
	return _enemies





func register_active_enemy(id:int) -> void:
	if not _enemies.has(id):
		return
	var enemy = _enemies[id]
	if enemy == null:
		return;
	_active_enemies[id] = enemy;
	

func unregister_active_enemy(id:int) -> void:
	# unregister enemy
	if _active_enemies.has(id):
		_active_enemies.erase(id);
		
func get_active_enemy_by_id(id: int) -> Enemy_controller:
	if _active_enemies.has(id):
		return _active_enemies[id]
	return null		
func get_all_active_enemies() -> Dictionary:
	_cleanup_active_enemies()
	return _active_enemies;

func get_active_enemy_count() -> int:
	_cleanup_active_enemies()
	return _active_enemies.size()

func _cleanup_active_enemies() -> void:
	var to_remove: Array = []
	for id in _active_enemies.keys():
		var enemy = _active_enemies[id]
		if enemy == null:
			to_remove.append(id)
			continue
		if not is_instance_valid(enemy):
			to_remove.append(id)
			continue
		if enemy.is_death:
			to_remove.append(id)
	for id in to_remove:
		_active_enemies.erase(id)
