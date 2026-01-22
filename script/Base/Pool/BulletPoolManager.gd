extends Node
class_name BulletPoolManager


#MEDIUM_ROUND_BULLET,
var pools: Dictionary = {}

func _ready() -> void:
	# auto scan all pools
	for child in get_children():
		if child is bullet_pool:
			var pool := child as bullet_pool
			pools[pool.get_pool_name()] = pool
			

	
func _preload_order(dict: Dictionary) -> void:
	for pool_name in dict.keys():
		var num: int = int(dict[pool_name])
		_preload(pool_name, num);
		
		
func _preload(pool_name: String, num: int) -> void:
	var pool = get_pool(pool_name)
	if pool:
		pool.preload_bullets(num);
		
		

func get_pool(pool_name: String):
	if pools.has(pool_name):
		return pools[pool_name]
	push_warning("Bullet pool not found: %s" % pool_name)
	return null
	
func spawn_bullet(pool_name: String):
	if pools.has(pool_name):
		return pools[pool_name].spawn_bullet();
	push_warning("Bullet pool not found: %s" % pool_name)
	return null
	
	
# 
func spawns_bullet(pool_name: String, num: int):
	if pools.has(pool_name):
		return pools[pool_name].spawn_bullets(num);
	push_warning("Bullet pool not found: %s" % pool_name)
	return null
	

func _deactivate_bullet(pool_name: String, bullet: Node) -> void:
	var pool = get_pool(pool_name);
	if pool:
		pool._on_bullet_deactivated(bullet);
	
func _deactivate_bullets(pool_name: String, bullet_scenes: Array) -> void:
	var pool = get_pool(pool_name);
	if pool:
		pool._on_bullet_deactivateds(bullet_scenes);

# clear
func clear(bulletType: String) -> void:
	var pool = get_pool(bulletType)
	if pool:
		pool.clear()

func clear_all():
	for p in pools.values():
		p.clear()
