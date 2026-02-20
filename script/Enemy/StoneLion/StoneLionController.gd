extends Enemy_controller
class_name StoneLionController

@onready var state_hub: State_hub = $StateHub

var slam_cooldown: float = 0.0
var flame_cooldown: float = 0.0
var recover_timer: float = 0.0

func _init() -> void:
	name = "StoneLionBoss"
	_character = StoneLion.new()
	_logic = enemy_logic.new(self, _character)
	team = TEAM.ENEMY

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	slam_cooldown = max(0.0, slam_cooldown - delta)
	flame_cooldown = max(0.0, flame_cooldown - delta)
	recover_timer = max(0.0, recover_timer - delta)
	super._physics_process(delta)
	rotation = 0.0

func activate(behavoir_code: String = "", sprite_code: int = 0) -> void:
	var selector = State_selector.new()
	selector.state_name = "StoneLionSelector"

	var recover_state = StoneLionRecoverState.new()
	recover_state.priority = 40
	selector.child_states.append(recover_state)

	var slam_state = StoneLionJumpSlamState.new()
	slam_state.priority = 30
	selector.child_states.append(slam_state)

	var flame_state = StoneLionFlameFanState.new()
	flame_state.priority = 20
	selector.child_states.append(flame_state)

	var move_state = StoneLionMoveState.new()
	move_state.priority = 10
	selector.child_states.append(move_state)
	selector.default_state = move_state

	state_hub.set_up_root(selector)

	slam_cooldown = float(stats.get("slam_cooldown_initial", 0.6))
	flame_cooldown = float(stats.get("flame_cooldown_initial", 1.2))
	recover_timer = 0.0

	super.activate(behavoir_code)

func has_player() -> bool:
	return GameManager.player_manager and GameManager.player_manager.player != null

func _get_target_node() -> Node2D:
	if has_player():
		return GameManager.player_manager.player
	return null

func get_player_position_or(fallback: Vector2) -> Vector2:
	var target = _get_target_node()
	if target != null:
		if target.has_method("get_actor_position"):
			return target.get_actor_position()
		return target.global_position
	return fallback

func get_player_distance() -> float:
	var target = _get_target_node()
	if target == null:
		return INF
	if target.has_method("get_actor_position"):
		return global_position.distance_to(target.get_actor_position())
	return global_position.distance_to(target.global_position)

func should_use_jump_slam() -> bool:
	if recover_timer > 0.0:
		return false
	if slam_cooldown > 0.0:
		return false
	if not has_player():
		return false

	var min_dist = float(stats.get("slam_min_range", 100.0))
	var max_dist = float(stats.get("slam_trigger_range", 360.0))
	var dist = get_player_distance()
	return dist >= min_dist and dist <= max_dist

func should_use_flame_fan() -> bool:
	if recover_timer > 0.0:
		return false
	if flame_cooldown > 0.0:
		return false
	if not has_player():
		return false

	var min_dist = float(stats.get("flame_min_range", 140.0))
	var max_dist = float(stats.get("flame_trigger_range", 520.0))
	var dist = get_player_distance()
	return dist >= min_dist and dist <= max_dist

func request_flame_fan() -> void:
	var cast_script = [
		{
			"action": "cast",
			"type": "fan_shape",
			"aim": "OBJECT",
			"object": _get_target_node(),
			"pool": str(stats.get("flame_pool", "MEDIUM_ROUND_BULLET")),
			"color": str(stats.get("flame_color", "RED")),
			"damage": int(stats.get("flame_damage", 10)),
			"speed": float(stats.get("flame_speed", 190.0)),
			"spread": float(stats.get("flame_spread", 42.0)),
			"count": int(stats.get("flame_count", 9)),
			"time": int(stats.get("flame_times", 3)),
			"interval": float(stats.get("flame_interval", 0.35))
		}
	]
	scheduler.preemption(cast_script)

func do_slam_impact() -> void:
	var slam_radius = float(stats.get("slam_radius", 100.0))
	var slam_damage = float(stats.get("slam_damage", 16.0))

	var target = _get_target_node()
	if target != null and target.global_position.distance_to(global_position) <= slam_radius:
		if target is Player_controller:
			var player = target as Player_controller
			if "_character" in player and player._character != null:
				player._character.hp = max(0.0, player._character.hp - slam_damage)

	if vfx_parser:
		vfx_parser.setup({
			"name": str(stats.get("slam_vfx", "Explosion2")),
			"position": global_position,
			"life": float(stats.get("slam_vfx_life", 0.9)),
			"scale": float(stats.get("slam_vfx_scale", 1.35)),
			"amount": int(stats.get("slam_vfx_amount", 36)),
			"front": true
		})
