# VFX_spawner.gd
extends Node2D
class_name VFX_spawner

@export var pool_manager_path: NodePath           
@export var vfx_pool_manager_node_name: String = "VFXPoolManager"
@export var default_vfx_name: String = ""         
@export var vfx_container_front:Node2D;
@export var vfx_container_back:Node2D;
var _vfx_pool_manager: VFX_pool_manager = null
var _owner_controller: Node = null
var spawner_id: int;


func _ready() -> void:
	
	_owner_controller = get_parent()
	_vfx_pool_manager = PoolManager.vfx_pool_manager; 
	vfx_container_front = get_tree().current_scene.get_node("VFXContainerFront");
	vfx_container_back = get_tree().current_scene.get_node("VFXContainerBack")
	GameManager.vfx_manager.register_vfx_spawner(self);
# Main API: spawn by configure
func spawn(cfg: VFX_request) -> VFX_instance:
	var key := cfg.vfx_name
	if key == "":
		key = default_vfx_name
	if key == "":
		# no vfx specified -> do nothing, but still "valid"
		return null

	var pool := _vfx_pool_manager.get_pool(key)
	if pool == null:
		push_warning("VFX_spawner: pool not found for vfx_name = " + key)
		return null

	var inst := pool.spawn() as VFX_instance
	if inst == null:
		return null

	# Decide parent: attach to owner or to current scene / vfx container
	if cfg.attach_to_owner and _owner_controller != null:
		_owner_controller.add_child(inst)
	else:
		# preferred: put VFX under a global VFX container if you have one
		
		if cfg.is_front :
			vfx_container_front.add_child(inst)
		else:
			vfx_container_back.add_child(inst)

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



	return inst


# Convenience API: simple one-shot vfx
func emit(vfx_name: String, pos: Vector2, life: float = 0.25, sc: Vector2 = Vector2.ONE) -> void:
	var cfg := VFX_request.new()
	cfg.simple(vfx_name, pos, life, sc)
	spawn(cfg)
