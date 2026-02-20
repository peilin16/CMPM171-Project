extends StoneLionState
class_name StoneLionJumpSlamState

var _active: bool = false
var _elapsed: float = 0.0
var _duration: float = 0.9
var _arc_height: float = 140.0
var _start_pos: Vector2 = Vector2.ZERO
var _target_pos: Vector2 = Vector2.ZERO
var _did_slam: bool = false

func _init() -> void:
	state_name = "JumpSlam"
	can_be_interrupted = false

func trigger(controller) -> bool:
	var c = get_stone_lion_controller(controller)
	if c == null:
		return false
	if _active:
		return true
	return c.should_use_jump_slam()

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_stone_lion_controller(controller)
	if c == null:
		return

	_active = true
	_elapsed = 0.0
	_did_slam = false
	_start_pos = c.global_position
	_duration = max(0.2, float(c.stats.get("slam_jump_duration", 0.9)))
	_arc_height = float(c.stats.get("slam_jump_height", 150.0))

	var to_player = c.get_player_position_or(c.global_position) - _start_pos
	var max_dist = float(c.stats.get("slam_jump_range", 240.0))
	if to_player.length() > max_dist:
		to_player = to_player.normalized() * max_dist
	_target_pos = _start_pos + to_player

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var c = get_stone_lion_controller(controller)
	if c == null:
		_active = false
		return

	_elapsed += delta
	var t = clamp(_elapsed / _duration, 0.0, 1.0)
	var base_pos = _start_pos.lerp(_target_pos, t)
	var y_offset = -4.0 * _arc_height * t * (1.0 - t)
	c.global_position = base_pos + Vector2(0, y_offset)

	if t >= 1.0 and not _did_slam:
		_did_slam = true
		c.do_slam_impact()
		_active = false

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_stone_lion_controller(controller)
	if c:
		c.recover_timer = float(c.stats.get("slam_recover", 0.7))
		c.slam_cooldown = float(c.stats.get("slam_cooldown", 2.6))
