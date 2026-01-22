extends Resource
class_name Custom_pool

@export var preload_count: int = 0
var citation#: PackedScene   # bullet_scene
@export var pool_name:= "Pool";
var available_instances: Array = []
var active_instances: Array = []



func get_pool_name() -> String:
	return pool_name   # Unique Pool Name


# ---------- preload ----------
func preload_instance(count: int) -> void:
	for i in range(count):
		var b = _create_new();
		deactivated(b)
		available_instances.append(b)

# spawn
func spawn() -> Node:
	var new_instance: Node = null

	
	if available_instances.size() > 0:
		new_instance = available_instances.pop_back()
	else:
		new_instance = _create_new()

	# 
	if "visible" in new_instance:
		new_instance.visible = true
	
	active_instances.append(new_instance)
	return new_instance;

func spawn_mutiple(num:int = 1)->Array :		
	var new_scene_array= [];
	for i in range(num):
		var b = spawn();
		new_scene_array.push_back(b);
	return new_scene_array;
	
	
func _create_new() -> Node:
	if citation == null:
		push_error("bullet_pool: bullet_scene is not assigned!")
		return null
	var instance = citation.duplicate();
	
	preload_count += 1;
	return instance

# ---------- deactivated ----------
func deactivated(_instance: Node) -> void:
	# remove from active array
	if _instance in active_instances:
		active_instances.erase(_instance)
	_instance.global_position  =  Vector2(-9999, -9999) # 子弹出生点	

	
	
		
		
# ---------- recycle bullet ----------
func _deactivate_all() -> void:
	for b in active_instances:
		deactivated(b)
		if not (b in available_instances):
			available_instances.append(b)
	active_instances.clear()

# ---------- free all scene ----------
func clear() -> void:
	for b in active_instances:
		ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		b.queue_free()
	for b in available_instances:
		ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		b.queue_free()
	active_instances.clear()
	available_instances.clear()
