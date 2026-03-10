extends StoneLionState
class_name StoneLionMoveState

func _init() -> void:
	state_name = "Move"

func trigger(controller) -> bool:
	return true

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var c = get_stone_lion_controller(controller)
	if c == null:
		return
	c.set_visual_state("idle")
	c.velocity = Vector2.ZERO
	c.move_and_slide()
