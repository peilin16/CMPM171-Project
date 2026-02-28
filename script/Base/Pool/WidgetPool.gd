extends Node
class_name Widget_pool


@export var preload_count: int = 0
@export var main_scene: PackedScene   
@export var pool_name:= "WidgetPool";
var available_items: Array = []
var active_items: Array = []



func get_pool_name() -> String:
	return pool_name   # Unique Pool Name


# ---------- preload ----------
func preload_items(count: int) -> void:
	for i in range(count):
		var b = _create_item()
		_deactivate_item(b)
		available_items.append(b)

# spawn
func spawn_item() -> Node:
	var new_scene: Widget_controller = null


	if available_items.size() > 0:
		new_scene = available_items.pop_back()
	else:

		new_scene = _create_item()


	if "visible" in new_scene:
		new_scene.visible = true

	#character_scene._character.is_active = true
	#character_scene._character.is_off_screen = false;
	#character_scene.activate();
	active_items.append(new_scene)
	return new_scene
		
	
func _create_item() -> Node:
	if main_scene == null:
		push_error("main is not assigned!")
		return null
	var new_scene = main_scene.instantiate()
	# connet signal of _enemy
	#GameManager.enemy_manager.register_enemy(new_scene);
	preload_count += 1;
	return new_scene

# ---------- deactivated ----------
func _on_item_deactivated(_scene: Widget_controller) -> void:
	# remove from active array
	if _scene in active_items:
		active_items.erase(_scene)
	
	if not (_scene in available_items):
		_deactivate_item(_scene)
		available_items.append(_scene)
	#_scene.widget._init();		
	_scene.global_position = Vector2(999999,999999);
# ---------- singal  deactive ----------
func _deactivate_item(new_scene: Node) -> void:
	#new_scene.widget._init();
	new_scene.visible = false
	#new_scene.widget.is_active = false

	
	new_scene.global_position  =  Vector2(-9999, -9999) # 
	
	new_scene.position = Vector2(-9999, -9999);	
		
# ---------- recycle enemy ----------
func _deactivate_all() -> void:
	for b in active_items:
		_deactivate_item(b)
		if not (b in available_items):
			available_items.append(b)
	active_items.clear()

# ---------- free all scene ----------
func clear() -> void:
	#for b in active_items:
		#ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		#b.queue_free()
	#for b in available_items:
		#ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		#b.queue_free()
	active_items.clear()
	available_items.clear()
