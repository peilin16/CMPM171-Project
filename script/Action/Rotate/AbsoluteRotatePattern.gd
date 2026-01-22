# Absolute_rotate_pattern.gd
extends Rotate_pattern
class_name Absolute_rotate_pattern

func _ready(runner: Runner, configure: Configure) -> void:
	rotate_runner = runner as Rotate_runner;
	rotate_configure = configure as Absolute_rotate_configure;
	super._ready(runner, configure);

func play(runner: Runner, configure: Configure, delta: float) -> bool:
	if not rotate_runner.is_ready:
		return false

	var remain :float= _dir_distance(record.current_deg, rotate_configure.target_angle, rotate_configure.is_clockwise)
	if remain <= rotate_configure.epsilon_deg:
		record.current_deg = rotate_configure.target_angle
		rotate_runner.apply_math_deg(record.current_deg)
		return false

	var step := _compute_step(remain, delta)
	if step <= 0.0:
		return true

	var sign := -1.0 if rotate_configure.is_clockwise else 1.0
	var actual :float= min(step, remain)

	record.current_deg = _wrap_deg(record.current_deg + sign * actual)
	rotate_runner.apply_math_deg(record.current_deg)
	return true

func _dir_distance(cur: float, target: float, clockwise: bool) -> float:
	# both are math deg [0,360)
	if clockwise:
		return fposmod(cur - target, 360.0)
	else:
		return fposmod(target - cur, 360.0)

func _compute_step(remain: float, dt: float) -> float:
	if rotate_configure.acceleration < 0.0 and rotate_configure.deceleration < 0.0:
		return rotate_configure.max_speed_deg * dt

	if rotate_configure.acceleration > 0.0:
		record.current_speed_deg = min(record.current_speed_deg + rotate_configure.acceleration * dt, rotate_configure.max_speed_deg)
	else:
		record.current_speed_deg = rotate_configure.max_speed_deg

	if rotate_configure.deceleration > 0.0:
		var v_stop := sqrt(max(2.0 * rotate_configure.deceleration * remain, 0.0))
		record.current_speed_deg = min(record.current_speed_deg, v_stop)

	return record.current_speed_deg * dt

func _wrap_deg(d: float) -> float:
	return fposmod(d, 360.0)
