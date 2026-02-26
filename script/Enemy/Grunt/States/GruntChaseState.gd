extends GruntState
class_name GruntChaseState

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var grunt_ctrl = get_grunt_controller(controller)
	var stats = controller.stats
	
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

func _apply_avoidance(controller: GruntController, velocity: Vector2, stats: Dictionary) -> Vector2:
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
		# Simple heuristic: Steer away from obstacles
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
