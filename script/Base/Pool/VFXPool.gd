# VFX_pool.gd
extends Node
class_name VFX_pool

@export var effect_id: String = ""
@export var vfx_scene: PackedScene
@export var preload_count: int = 10

# inactive instances (stored under this pool node)
var _free_list: Array[VFX_instance] = []
var _active_list: Array[VFX_instance] = []



func _ready() -> void:
	pass

func _preload(count:int = 10) -> void:
	preload_count = count;
	if vfx_scene == null:
		return
	for i in preload_count:
		var inst := _create_one()
		if inst != null:
			_free_list.append(inst)

func spawn() -> VFX_instance:
	var inst: VFX_instance
	if _free_list.is_empty():
		inst = _create_one()
	else:
		inst = _free_list.pop_back()

	if inst == null:
		return null

	_active_list.append(inst)
	inst.visible = true
	inst.process_mode = Node.PROCESS_MODE_INHERIT
	return inst

func _create_one() -> VFX_instance:
	if vfx_scene == null:
		return null
	var inst := vfx_scene.instantiate() as VFX_instance
	add_child(inst)
	inst.visible = false
	inst.process_mode = Node.PROCESS_MODE_DISABLED
	return inst


func recycle(inst: VFX_instance) -> void:
	if inst == null:
		return

	# Remove from active list if exists
	var idx := _active_list.find(inst)
	if idx != -1:
		_active_list.remove_at(idx)

	inst.visible = false
	inst.process_mode = Node.PROCESS_MODE_DISABLED

	# Optional: move to pool node position to avoid confusion
	inst.position = Vector2.ZERO
	inst.rotation = 0.0
	inst.scale = Vector2.ONE

	# Put back into pool
	_free_list.append(inst)
