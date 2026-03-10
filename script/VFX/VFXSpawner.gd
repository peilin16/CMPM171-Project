# VFX_spawner.gd
extends Node2D

@export var pool_manager_path: NodePath           
@export var vfx_pool_manager_node_name: String = "VFXPoolManager"
@export var default_vfx_name: String = ""         
@export var vfx_container_front:Node2D;
@export var vfx_container_back:Node2D;
var _vfx_pool_manager = null
var _owner_controller: Node = null
var spawner_id: int;


func _ready() -> void:
	
	_owner_controller = get_parent()
	_vfx_pool_manager = PoolManager.vfx_pool_manager; 
	var scene = get_tree().current_scene
	vfx_container_front = scene.get_node_or_null("VFXContainerFront") as Node2D
	vfx_container_back = scene.get_node_or_null("VFXContainerBack") as Node2D
	if vfx_container_front == null:
		vfx_container_front = scene.get_node_or_null("VFXContainer") as Node2D
	if vfx_container_back == null:
		vfx_container_back = scene.get_node_or_null("VFXContainer") as Node2D
	if vfx_container_front == null:
		vfx_container_front = scene
	if vfx_container_back == null:
		vfx_container_back = scene
	GameManager.vfx_manager.register_vfx_spawner(self);
# Main API: spawn by configure
func spawn(cfg: VFX_request) -> VFX_instance:
	var key := cfg.vfx_name
	if key == "":
		key = default_vfx_name
	if key == "":
		# no vfx specified -> do nothing, but still "valid"
		return null

	var pool = _vfx_pool_manager.get_pool(key)
	if pool == null:
		push_warning("VFX_spawner: pool not found for vfx_name = " + key)
		return null

	var raw_inst = pool.spawn()
	if raw_inst == null:
		return null

	var inst := raw_inst as VFX_instance
	if inst == null:
		if raw_inst is CanvasItem:
			raw_inst.visible = false
		if pool.has_method("recycle"):
			pool.recycle(raw_inst)
		push_warning("VFX_spawner: vfx root must extend VFX_instance for vfx_name = " + key)
		return null

	# Decide parent: attach to owner or to current scene / vfx container
	var target_parent: Node = null
	if cfg.attach_to_owner and _owner_controller != null:
		target_parent = _owner_controller
	else:
		# preferred: put VFX under a global VFX container if you have one
		if cfg.is_front:
			target_parent = vfx_container_front
		else:
			target_parent = vfx_container_back

	if target_parent == null:
		target_parent = get_tree().current_scene

	if inst.get_parent() != target_parent:
		if inst.get_parent() != null:
			inst.get_parent().remove_child(inst)
		target_parent.add_child(inst)

	# Keep z relative to chosen parent container.
	# This prevents "back" effects from dropping behind the map while still rendering behind characters.
	inst.z_as_relative = true
	if cfg.attach_to_owner and _owner_controller is CanvasItem:
		# when attached to owner, place just behind/in front of owner
		inst.z_index = (1 if cfg.is_front else -1)
	else:
		# when using global VFX containers, container z-order already separates front/back
		inst.z_index = 0

	# Apply transform
	var pos := cfg.spawn_position
	#if not cfg.use_global_position:
		## local offset relative to owner
		#var base := global_position
		#pos = base + cfg.local_offset
	inst.global_position = pos
	
	
	
	
	inst.rotation = cfg.rotation_rad
	

	# Apply runtime params
	inst.set_lifetime(cfg.lifetime)

	# Play (restart particles)
	inst.play()

	# Let instance know how to return to pool (optional pattern)
	inst.bind_pool(pool)

	#inst.particles.process_material.scale_min = cfg.scale_min
	#inst.particles.process_material.scale_max = cfg.scale_max
	inst.set_up_scale(cfg.scale_min, cfg.scale_max);
	inst.set_up_speed(cfg.speed_mul)
	if cfg.amount > 0:
		inst.set_up_amount(cfg.amount);

	return inst


# Convenience API: simple one-shot vfx
func emit(vfx_name: String, pos: Vector2, life: float = 0.25, sc: Vector2 = Vector2.ONE) -> void:
	var cfg := VFX_request.new()
	cfg.simple(vfx_name, pos, life, sc)
	spawn(cfg)
