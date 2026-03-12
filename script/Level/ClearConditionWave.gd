# Wave.gd
extends Wave
class_name Clear_condition_wave

const CLEANUP_INTERVAL := 5.0
var _cleanup_timer: float = 0.0

func start(sub: Sub_director) -> void:
	_cleanup_timer = 0.0

func update(sub: Sub_director, delta: float) -> void:
	_cleanup_timer += delta
	# Periodically clean up broken enemies (invisible, off-screen, no HP)
	if _cleanup_timer >= CLEANUP_INTERVAL:
		_cleanup_timer = 0.0
		_cleanup_broken_enemies()

func is_done(sub: Sub_director) -> bool:
	if GameManager.enemy_manager == null:
		return true
	var count: int = GameManager.enemy_manager.get_active_enemy_count()
	if count == 0:
		return true
	return false

const MAX_ENEMY_DISTANCE := 3000.0
const STUCK_POSITION_THRESHOLD := 5.0
const STUCK_TIME_LIMIT := 15.0
var _prev_positions: Dictionary = {}
var _stuck_timers: Dictionary = {}

func _cleanup_broken_enemies() -> void:
	var actives: Dictionary = GameManager.enemy_manager.get_all_active_enemies()
	var player_pos: Vector2 = Vector2.ZERO
	if GameManager.player_manager and GameManager.player_manager.player:
		player_pos = GameManager.player_manager.get_player_position()
	for id in actives.keys():
		var enemy = actives[id]
		if enemy == null or not is_instance_valid(enemy):
			continue
		# Off-screen at pool parking position
		if enemy.global_position.x <= -9000 or enemy.global_position.y <= -9000:
			enemy.is_death = true
			enemy.deactivate()
			continue
		# Invisible but registered as active
		if not enemy.visible:
			enemy.is_death = true
			enemy.deactivate()
			continue
		# Already dead but somehow still in active list
		if enemy.is_death and enemy.has_method("deactivate"):
			enemy.deactivate()
			continue
		# Too far from player — spawned at wrong position or walked off map
		if enemy.global_position.distance_to(player_pos) > MAX_ENEMY_DISTANCE:
			enemy.is_death = true
			enemy.deactivate()
			continue
		# Stuck detection — enemy not moving for too long
		var prev_pos: Vector2 = _prev_positions.get(id, enemy.global_position)
		if enemy.global_position.distance_to(prev_pos) < STUCK_POSITION_THRESHOLD:
			_stuck_timers[id] = _stuck_timers.get(id, 0.0) + CLEANUP_INTERVAL
			if _stuck_timers[id] >= STUCK_TIME_LIMIT:
				enemy.is_death = true
				enemy.deactivate()
				continue
		else:
			_stuck_timers[id] = 0.0
		_prev_positions[id] = enemy.global_position
