extends Node
class_name Widget_pool_manager


#MEDIUM_ROUND_BULLET,
var pools: Dictionary[String, Widget_pool]

func _ready() -> void:
	# auto scan all pools
	for child in get_children():
		if child is Widget_pool:
			var pool := child as Widget_pool
			pools[pool.get_pool_name()] = pool
			

	
func _preload_order(dict: Dictionary) -> void:
	for pool_name in dict.keys():
		var num: int = int(dict[pool_name])
		_preload(pool_name, num);
		
		
func _preload(pool_name: String, num: int) -> void:
	var pool = get_pool(pool_name)
	if pool:
		pool.preload_items(num);
		
		

func get_pool(pool_name: String):
	if pools.has(pool_name):
		return pools[pool_name]
	push_warning("Widget pool not found: %s" % pool_name)
	return null
	
func spawn_widget(pool_name: String):
	if pools.has(pool_name):
		return pools[pool_name].spawn_item();
	push_warning("Widget pool not found: %s" % pool_name)
	return null
	
	
# 
func spawn_widgets(pool_name: String, num: int)->Array:
	if pools.has(pool_name):
		var arr:Array[Widget_controller]= []
		var pool:Widget_pool = pools[pool_name];
		for i in range(num):
			arr.append(pool.spawn_item());
		return arr;
		
	push_warning("Bullet pool not found: %s" % pool_name)
	return []
	

func _deactivate_widget(pool_name: String, widget: Widget_controller) -> void:
	var pool = get_pool(pool_name);
	if pool:
		pool._on_item_deactivated(widget);
	
func _deactivate_widgets(pool_name: String, _scenes: Array) -> void:
	var pool = get_pool(pool_name);
	if pool:
		pool._on_item_deactivated(_scenes);

# clear
func clear(pool_name: String) -> void:
	var pool = get_pool(pool_name)
	if pool:
		pool.clear()

func clear_all():
	for p in pools.values():
		p.clear()
