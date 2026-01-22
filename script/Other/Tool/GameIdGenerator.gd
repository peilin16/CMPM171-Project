# GameIDGenerator.gd
extends Node
class_name Game_Id_generator

var _next_id: int = 1
var _recycled: Array[int] = []  

func generate_id() -> int:
	if _recycled.size() > 0:
		return _recycled.pop_back()
	var id = _next_id
	_next_id += 1
	return id

func recycle_id(id: int) -> void:
	# recycle
	if id not in _recycled:
		_recycled.append(id)
