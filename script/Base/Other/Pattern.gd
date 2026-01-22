extends System
class_name Pattern
#init pattern
func _init() -> void:
	pass
#pattern ready
func _ready(runner: Runner, configure: Configure) ->void:
	pass
#play pattern
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	return true
#play pattern
func interrupt() -> void:
	pass
func deactive() ->void:
	pass
