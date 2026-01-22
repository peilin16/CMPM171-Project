extends Node

class_name BulletManager
var _bullets: Dictionary = {}  # {id: EnemyController}
var _active_bullets: Dictionary = {}  # {id: EnemyController}

func register_bullet(e: Bullet_controller) -> void:
	e.controller_id = ToolBar.gameIDGenerator.generate_id()
	_bullets[e.controller_id] = e

func unregister_bullet(id) -> void:
	# unregister enemy
	if _bullets.has(id):
		_bullets.erase(id)
		ToolBar.Game_Id_generator.recycle_id(id)
		print("Enemy unregistered:", id)
		

func get_bullet_by_id(id: int) -> Bullet_controller:
	if _bullets.has(id):
		return _bullets[id]
	return null

func get_all_bullets() -> Dictionary:
	return _bullets


func register_active_bullet(id:int) -> void:
	#var id = GameIdGenerator.generate_id()
	if _active_bullets.has(id):
		return
	_active_bullets[id] = _bullets[id];

func unregister_active_bullet(id) -> void:
	# unregister enemy
	if _active_bullets.has(id):
		_active_bullets.erase(id)
		#ToolBar.Game_Id_generator.recycle_id(id)
		#print("Enemy unregistered:", id)

func get_active_bullet_by_id(id: int) -> Bullet_controller:
	if _active_bullets.has(id):
		return _active_bullets[id]
	return null

func get_all_active_bullets() -> Dictionary:
	return _active_bullets
