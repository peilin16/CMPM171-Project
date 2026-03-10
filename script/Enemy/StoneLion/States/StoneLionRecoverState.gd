extends StoneLionState
class_name StoneLionRecoverState

func _init() -> void:
	state_name = "Recover"
	can_be_interrupted = false

func trigger(controller) -> bool:
	var c = get_stone_lion_controller(controller)
	return c != null and c.recover_timer > 0.0

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_stone_lion_controller(controller)
	if c:
		c.set_visual_state("idle")
		c.velocity = Vector2.ZERO

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var c = get_stone_lion_controller(controller)
	if c:
		c.velocity = c.velocity.move_toward(Vector2.ZERO, 180.0 * delta)
		c.move_and_slide()
