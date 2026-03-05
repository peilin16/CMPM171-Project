extends StoneLionState
class_name StoneLionFlameFanState

var _active: bool = false
var _timeout: float = 0.0

func _init() -> void:
	state_name = "FlameFan"
	can_be_interrupted = false

func trigger(controller) -> bool:
	var c = get_stone_lion_controller(controller)
	if c == null:
		return false
	if _active:
		return true
	return c.should_use_flame_fan()

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_stone_lion_controller(controller)
	if c == null:
		return

	c.set_visual_state("shoot")
	c.velocity = Vector2.ZERO
	c.request_flame_fan()
	_active = true
	_timeout = float(c.stats.get("flame_total_timeout", 2.6))

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	var c = get_stone_lion_controller(controller)
	if c == null:
		_active = false
		return

	_timeout -= delta
	if c.scheduler and c.scheduler.is_finish():
		_finish_flame(c)
	if _timeout <= 0.0:
		_finish_flame(c)

func _finish_flame(c: StoneLionController) -> void:
	if not _active:
		return
	_active = false
	c.set_visual_state("idle")
	c.recover_timer = float(c.stats.get("flame_recover", 0.8))
	c.flame_cooldown = float(c.stats.get("flame_cooldown", 3.8))

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	var c = get_stone_lion_controller(controller)
	if c:
		if _active:
			_finish_flame(c)
