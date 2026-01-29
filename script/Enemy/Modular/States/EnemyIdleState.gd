extends Enemy_state
class_name Enemy_idle_state

@export var duration: float = 1.0
var _timer: float = 0.0

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	_timer = 0.0
	get_scheduler(controller).stop()

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	_timer += delta

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return _timer >= duration
