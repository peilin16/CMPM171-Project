extends Move_pattern
class_name Linear_move_pattern

var _current_speed: float = 0.0
var _elapsed: float = 0.0
var _last_dir: Vector2 = Vector2.RIGHT

# NEW: lock direction for "aim target then continue"
var _locked_dir: Vector2 = Vector2.ZERO
var _use_locked_dir: bool = false

func _ready(runner: Runner, configure: Configure) -> void:
	if configure is Direction_move_configure:
		move_configure = configure as Direction_move_configure;
	elif configure is Target_move_configure:
		move_configure = configure as Target_move_configure;
	super._ready(runner, configure)
	move_runner = runner as Move_runner
	_elapsed = 0.0
	_current_speed = 0.0
	_last_dir = Vector2.RIGHT
	_locked_dir = Vector2.ZERO
	_use_locked_dir = false
	record = Move_data.new();
	
	# If target mode + continue, lock direction once (aim mode)
	if move_configure is Target_move_configure:
		move_configure= configure as Target_move_configure
		if move_configure.is_continue:
			var start := move_configure.start
			if start == Vector2.ZERO and move_runner and move_runner.controller:
				start = move_runner.controller.get_actor_position()
				move_configure.start = start

			if move_configure.target != Vector2.ZERO:
				_locked_dir = (move_configure.target - start).normalized()
				_use_locked_dir = (_locked_dir != Vector2.ZERO);
	record.reset(move_configure.start);
	
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	_elapsed += delta
	#var c := configure as Move_configure
	#if c == null:
		#return true

	# 1) direction
	var dir := _compute_dir(move_runner, configure)
	if dir == Vector2.ZERO:
		dir = _last_dir
	else:
		_last_dir = dir

	# 2) speed
	_current_speed = _update_speed(_current_speed, move_configure, delta)
	_current_speed = min(_current_speed, move_configure.max_velocity)
	if _current_speed < 0.0:
		_current_speed = 0.0

	# 3) move
	var offset := dir * _current_speed * delta
	if move_configure.wave != 0.0:
		var perp := Vector2(-dir.y, dir.x)
		var wave_offset := perp * sin(_elapsed * 4.0) * move_configure.wave
		offset += wave_offset * delta

	var pos := move_runner.get_actor_position()
	pos += offset
	move_runner.controller.set_actor_position(pos)

	if record:
		record.record_motion(pos, delta);

	# 5) finish condition
	if configure is Direction_move_configure:
		var dc := configure as Direction_move_configure
		return _elapsed >= dc.move_sec

	if configure is Target_move_configure:
		#var tc := configure as Target_move_configure

		# IMPORTANT: if continue, never "arrive & stop"
		if move_configure.is_continue:
			return false

		# normal target travel: stop at destination
		var dist := pos.distance_to(move_configure.target)
		if dist <= 1.0:
			move_runner.controller.set_actor_position(move_configure.target)
			return true
		return false

	return false

func _compute_dir(r: Move_runner, configure: Configure) -> Vector2:
	# NEW: locked aim direction
	if _use_locked_dir:
		return _locked_dir

	if configure is Target_move_configure:
		#var move_configure := configure as Target_move_configure
		if move_configure.target == Vector2.ZERO:
			return Vector2.ZERO
		return (move_configure.target - r.controller.get_actor_position()).normalized()

	if configure is Direction_move_configure:
		#var dc := configure as Direction_move_configure
		return Vector2.RIGHT.rotated(deg_to_rad(move_configure.direction_degree)).normalized()

	return Vector2.ZERO
	
func _update_speed(v: float, c: Move_configure, dt: float) -> float:
	# no accel/decel: jump to max
	if c.acceleration < 0.0 and c.deceleration < 0.0:
		return c.max_velocity

	# if accel enabled: accelerate up to max
	if c.acceleration >= 0.0 and v < c.max_velocity:
		v += c.acceleration * dt

	# decel 这里先不在 linear 里自动触发（因为你没给“何时开始减速”的触发条件）
	# 以后你可以在 Target_move_configure 增加 decel_distance 或在 Velocity pattern 里协调
	return v
