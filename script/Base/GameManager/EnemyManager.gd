extends Node
# EnemyManager.gd
class_name EnemyManager

var _enemies: Dictionary = {}  # {id: EnemyController}
var _active_enemies: Dictionary = {}  # {id: EnemyController}
func register_enemy(e: Enemy_controller) -> int:
	var id = ToolBar.gameIDGenerator.generate_id()
	_enemies[id] = e
	e.controller_id = id   # 把 id 回写给敌人本身
	print("Enemy registered:", id, e)
	return id

func unregister_enemy(e: Enemy_controller) -> void:
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
	return _active_enemies;
