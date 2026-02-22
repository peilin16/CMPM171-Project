extends GruntPlusState
class_name GruntPlusIdleState

func _init() -> void:
	state_name = "Idle"

func trigger(controller) -> bool:
	var c = get_grunt_plus_controller(controller)
	if c and c.idle_timer > 0:
		return true
	return false

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	# Animation code would go here
	pass

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var c = get_grunt_plus_controller(controller)
	if c:
		c.idle_timer -= delta
		if c.velocity.length() > 0:
			c.velocity = c.velocity.move_toward(Vector2.ZERO, 200 * delta) # Friction
			c.move_and_slide()

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_grunt_plus_controller(controller)
	if c:
		c.ready_to_shoot = true # Enable shooting again after idle sequence
