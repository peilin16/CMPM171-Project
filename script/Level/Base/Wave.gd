# Wave.gd
extends Resource
class_name Wave

var _is_ready:bool = false;
func start(sub: Sub_director) -> void:
	pass

func update(sub: Sub_director, delta: float) -> bool:
	return true


func end(sub: Sub_director) -> void:
	pass
	
