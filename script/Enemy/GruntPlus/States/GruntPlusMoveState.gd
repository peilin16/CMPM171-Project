extends GruntPlusState
class_name GruntPlusMoveState

func _init() -> void:
	state_name = "Move"

func trigger(controller) -> bool:
	return true # Default state

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var grunt_ctrl = get_grunt_plus_controller(controller)
	var stats = get_stats(controller)
	
	if not GameManager.player_manager or not GameManager.player_manager.player:
		return
		
	var target_pos = GameManager.player_manager.get_player_position()
	var move_speed = stats.get("move_speed", 100.0)
	var desired_velocity = (target_pos - controller.global_position).normalized() * move_speed
	
	# VS-style: soft separation only, no raycast avoidance
	if grunt_ctrl != null:
		desired_velocity = grunt_ctrl.apply_horde_separation(desired_velocity, delta)
		
	controller.velocity = desired_velocity
	controller.move_and_slide()
