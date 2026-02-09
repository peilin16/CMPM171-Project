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
	
	# Avoidance
	if stats.get("avoidance_enabled", false):
		desired_velocity = _apply_avoidance(grunt_ctrl, desired_velocity, stats)
		
	controller.velocity = desired_velocity
	controller.move_and_slide()
	
	# Rotate towards velocity
	if controller.velocity.length() > 0.1:
		var target_angle = controller.velocity.angle()
		var turn_speed = stats.get("turn_speed", 5.0)
		controller.rotation = lerp_angle(controller.rotation, target_angle, turn_speed * delta)

func _apply_avoidance(controller: GruntPlusController, velocity: Vector2, stats: Dictionary) -> Vector2:
	if not controller.ray_center: return velocity
	
	var steer = Vector2.ZERO
	var speed = velocity.length()
	var dir = velocity.normalized()
	var avoidance_force = stats.get("avoidance_force", 2.0)
	
	# Check rays
	var center_hit = controller.ray_center.is_colliding()
	var left_hit = controller.ray_left.is_colliding()
	var right_hit = controller.ray_right.is_colliding()
	
	if center_hit or left_hit or right_hit:
		if center_hit:
			var normal = controller.ray_center.get_collision_normal()
			steer += normal * avoidance_force
			
		if left_hit:
			var normal = controller.ray_left.get_collision_normal()
			steer += normal * (avoidance_force * 0.5)
			
		if right_hit:
			var normal = controller.ray_right.get_collision_normal()
			steer += normal * (avoidance_force * 0.5)
			
		var new_dir = (dir + steer).normalized()
		return new_dir * speed
		
	return velocity
