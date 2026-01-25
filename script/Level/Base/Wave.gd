# Wave.gd
extends Resource
class_name Wave

var _is_ready:bool = false;
func start(sub: Sub_director) -> void:
	pass

func update(sub: Sub_director, delta: float) -> void:
	pass


func end(sub: Sub_director) -> void:
	pass
	
func is_done(sub: Sub_director) -> bool:
	return true
