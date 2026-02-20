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
	if not c.has_player():
		c.velocity = Vector2.ZERO
		c.move_and_slide()
		return

	var move_speed = float(c.stats.get("move_speed", 70.0))
	var target_pos = c.get_player_position_or(c.global_position)
	var desired_velocity = (target_pos - c.global_position).normalized() * move_speed
	c.velocity = desired_velocity
	c.move_and_slide()
