extends Enemy_state
class_name Enemy_move_state

@export var speed: float = 100.0
@export var angle: float = 0.0
@export var duration: float = 1.0
@export var move_type: String = "direction_linear"

var _trigger_sent: bool = false
var _scheduler_was_finished: bool = false

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	_trigger_sent = false
	var scheduler = get_scheduler(controller)
	
	var script = [
		{
			"action": "move",
			"type": move_type,
			"speed": speed,
			"angle": angle,
			"sec": duration
		}
	]
	
	scheduler.preemption(script)
	_trigger_sent = true

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	# Check if command was sent and scheduler finished
	return _trigger_sent and get_scheduler(controller).is_finish()
