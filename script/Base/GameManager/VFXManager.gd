extends Node
class_name VFX_manager

var _spawners: Dictionary = {}  # {id: spawner}
func register_vfx_spawner(e: VFX_spawner) -> int:
	var id = ToolBar.gameIDGenerator.generate_id()
	_spawners[id] = e
	e.spawner_id = id 
	#print("Enemy registered:", id, e)
	return id

func unregister_vfx_spawner(e: VFX_spawner) -> void:
	# unregister enemy
	for id in _spawners.keys():
		if _spawners[id] == e:
			_spawners.erase(id)
			ToolBar.Game_Id_generator.recycle_id(id)
			print("VFX unregistered:", id)
			return

func get_vfx_spawner(id: int) -> VFX_spawner:
	if _spawners.has(id):
		return _spawners[id]
	return null
