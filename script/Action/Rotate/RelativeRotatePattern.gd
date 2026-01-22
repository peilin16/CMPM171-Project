extends Rotate_pattern
class_name Relative_rotate_pattern

func _ready(runner: Runner, configure: Configure) -> void:
	rotate_runner = runner as Rotate_runner;
	rotate_configure = configure as Relative_rotate_configure;
	super._ready(runner, configure);


func play(runner: Runner, configure: Configure, delta: float) -> bool:
	if not rotate_runner.is_ready:
		return false

	# infinite mode for relative doesn't make sense; treat as use_target always
	var remain :float= rotate_configure.rotate_deg - record.rotated_deg
	if remain <= rotate_configure.epsilon_deg:
		# snap
		var sign :float= -1.0 if rotate_configure.is_clockwise else 1.0
		var final_deg := _wrap_deg(rotate_configure.start_deg + sign * rotate_configure.rotate_deg)
		record.current_deg = final_deg
		rotate_runner.apply_math_deg(final_deg)
		return false

	var step := _compute_step(remain, delta)
	if step <= 0.0:
		return true

	var sign2 :float= -1.0 if rotate_configure.is_clockwise else 1.0
	var actual :float= min(step, remain)

	record.rotated_deg += actual
	record.current_deg = _wrap_deg(record.current_deg + sign2 * actual)
	rotate_runner.apply_math_deg(record.current_deg)
	return true

func _compute_step(remain: float, dt: float) -> float:
	# no accel/decel => constant speed
	if rotate_configure.acceleration < 0.0 and rotate_configure.deceleration < 0.0:
		return rotate_configure.max_speed_deg * dt

	# update speed by acceleration
	if rotate_configure.acceleration > 0.0:
		record.current_speed_deg = min(record.current_speed_deg + rotate_configure.acceleration * dt, rotate_configure.max_speed_deg)
	else:
		record.current_speed_deg = rotate_configure.max_speed_deg

	# clamp by deceleration ability
	if rotate_configure.deceleration > 0.0:
		var v_stop := sqrt(max(2.0 * rotate_configure.deceleration * remain, 0.0))
		record.current_speed_deg = min(record.current_speed_deg, v_stop)

	return record.current_speed_deg * dt

func _wrap_deg(d: float) -> float:
	return fposmod(d, 360.0)
