extends Node
class_name Enemy_pool_manager


var pools: Dictionary = {}

func _ready() -> void:
	# auto scan all pools
	for child in get_children():
		if child is Enemy_pool:
			var pool := child as Enemy_pool
			pools[pool.get_pool_name()] = pool
			

	
func _preload_order(dict: Dictionary) -> void:
	for pool_name in dict.keys():
		var num: int = int(dict[pool_name])
		_preload(pool_name, num);
		
		
func _preload(pool_name: String, num: int) -> void:
	var pool = get_pool(pool_name)
	if pool:
		pool.preload_enemies(num);
		
		

func get_pool(pool_name: String):
	if pools.has(pool_name):
		return pools[pool_name]
	push_warning("Enemy pool not found: %s" % pool_name)
	return null
	
func spawn_enemy(pool_name: String):
	if pools.has(pool_name):
		return pools[pool_name].spawn_enemy();
	push_warning("Enemy pool not found: %s" % pool_name)
	return null
	
	
# 
func get_enemy(pool_name: String, num: int = 1):
	var pool = get_pool(pool_name)
	if pool:
		return pool.spawn_enemy();
	push_warning("Enemy pool not found: %s" % pool_name)
	return null
	

func _deactivate_enemy(pool_name: String, enemy: Enemy) -> void:
	var pool = get_pool(pool_name)
	if pool:
		pool._on_enemy_deactivated(enemy)
	


#clear
func clear(pool_name: String) -> void:
	var pool = get_pool(pool_name)
	if pool:
		pool.clear()

# clear all
func clear_all():
	for p in pools.values():
		p.clear()
