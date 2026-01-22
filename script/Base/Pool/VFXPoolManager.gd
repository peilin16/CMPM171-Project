# VFX_pool_manager.gd
extends Node
class_name VFX_pool_manager

# Optional: put a global container in scene (recommended)
@export var vfx_container_path: NodePath

var _pools: Dictionary = {}  # effect_id -> VFX_pool
var _container: Node = null


func _ready() -> void:
	_container = get_node_or_null(vfx_container_path)
	_register_child_pools()


func _register_child_pools() -> void:
	_pools.clear()
	for c in get_children():
		if c is VFX_pool:
			var p := c as VFX_pool
			if p.effect_id != "":
				_pools[p.effect_id] = p


func get_pool(effect_id: String) -> VFX_pool:
	if _pools.has(effect_id):
		return _pools[effect_id]
	return null


# high-level spawn
func spawn(effect_id: String) -> VFX_instance:
	var p := get_pool(effect_id)
	if p == null:
		push_warning("No VFX pool found for: %s" % effect_id)
		return null

	return p.spawn();
