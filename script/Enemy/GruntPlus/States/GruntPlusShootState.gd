extends GruntPlusState
class_name GruntPlusShootState

var _shoot_timer: float = 0.0
var _duration: float = 0.5

func _init() -> void:
	state_name = "Shoot"

func trigger(controller) -> bool:
	var c = get_grunt_plus_controller(controller)
	if not c: return false
	
	# 1. Busy check: checks if we are mid-animation
	# Note: Only considered valid if we are effectively 'running' this logic. 
	# Does state selector call trigger on active state? Yes.
	if _shoot_timer > 0:
		return true

	# 2. Start check
	if not c.ready_to_shoot:
		return false
		
	var stats = get_stats(controller)
	var range_val = stats.get("attack_range", 300.0)
	
	if not GameManager.player_manager or not GameManager.player_manager.player:
		return false
		
	var dist = controller.global_position.distance_to(GameManager.player_manager.get_player_position())
	
	if dist <= range_val:
		return true
		
	return false


func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_grunt_plus_controller(controller)
	var stats = get_stats(controller)
	
	_duration = stats.get("shoot_duration", 0.5)
	_shoot_timer = _duration
	
	if c:
		c.spawn_bullet()
		c.ready_to_shoot = false # Consume readiness
		c.velocity = Vector2.ZERO # Stop moving when shooting

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	_shoot_timer -= delta

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_grunt_plus_controller(controller)
	var stats = get_stats(controller)
	if c:
		c.idle_timer = stats.get("idle_duration", 1.0)
