extends Node 
class_name bullet_pool

@export var preload_count: int = 0
@export var bullet_scene: PackedScene   # bullet_scene
@export var pool_name:= "Pool";
var available_bullets: Array = []
var active_bullets: Array = []



func get_pool_name() -> String:
	return pool_name   # Unique Pool Name


# ---------- preload ----------
func preload_bullets(count: int) -> void:
	for i in range(count):
		var b = _create_bullet()
		_deactivate_bullet(b)
		available_bullets.append(b)

# spawn
func spawn_bullet() -> Node:
	var bullet_scene: Node = null

	
	if available_bullets.size() > 0:
		bullet_scene = available_bullets.pop_back()
	else:
		bullet_scene = _create_bullet()

	# 
	if "visible" in bullet_scene:
		bullet_scene.visible = true
	#if "active" in bullet:
	bullet_scene.bullet.is_active = true
	#if "monitoring" in bullet_scene:
	#bullet_scene.monitoring = true
	bullet_scene.bullet.is_off_screen = false;
	active_bullets.append(bullet_scene)
	return bullet_scene

func spawn_bullets(num:int = 1) :		
	var bullet_scene_array= [];
	for i in range(num):
		var b = spawn_bullet();
		bullet_scene_array.push_back(b);
	return bullet_scene_array;
	
	
func _create_bullet() -> Node:
	if bullet_scene == null:
		push_error("bullet_pool: bullet_scene is not assigned!")
		return null
	var bullet = bullet_scene.instantiate();
	GameManager.bullet_manager.register_bullet(bullet);
	# connet signal of bullet
	if bullet.has_signal("bullet_deactivated"):
		bullet.connect("bullet_deactivated", Callable(self, "_on_bullet_deactivated"));
	preload_count += 1;
	return bullet

# ---------- deactivated bullet ----------
func _on_bullet_deactivated(bullet_scene: Node) -> void:
	# remove from active array
	if bullet_scene in active_bullets:
		active_bullets.erase(bullet_scene)
	
	if not (bullet_scene in available_bullets):
		_deactivate_bullet(bullet_scene)
		available_bullets.append(bullet_scene)
	bullet_scene.bullet._init();		
	
# ---------- deactivated bullets ----------
func _on_bullet_deactivateds(bullet_scenes: Array) -> void:
	# remove from active array
	for element in bullet_scenes:
		_on_bullet_deactivated(element);
# ---------- singal bullet  deactive ----------
func _deactivate_bullet(bullet_scene: Node) -> void:
	bullet_scene.bullet._init();
	bullet_scene.visible = false
	bullet_scene.bullet.is_active = false
	#if "monitoring" in bullet_scene:
	#	bullet_scene.monitoring = false

	if "position" in bullet_scene:
		bullet_scene.global_position  =  Vector2(-9999, -9999) # 子弹出生点	
	elif "position" in bullet_scene:
		bullet_scene.position = Vector2(-9999, -9999);	
		
# ---------- recycle bullet ----------
func _deactivate_all() -> void:
	for b in active_bullets:
		_deactivate_bullet(b)
		if not (b in available_bullets):
			available_bullets.append(b)
	active_bullets.clear()

# ---------- free all scene ----------
func clear() -> void:
	for b in active_bullets:
		ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		b.queue_free()
	for b in available_bullets:
		ToolBar.Game_Id_generator.recycle_id(b.controller_id);
		b.queue_free()
	active_bullets.clear()
	available_bullets.clear()
	
