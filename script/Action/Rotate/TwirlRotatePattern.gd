# Twirl_rotate_pattern.gd
extends Rotate_pattern
class_name Twirl_rotate_pattern

#var r: Rotate_runner
#var cfg: Rotate_configure
var _total_rotate: float = 0.0

func _ready(runner: Runner, configure: Configure) -> void:
	rotate_configure as Twirl_rotate_configure
	
	rotate_configure.reset_runtime(rotate_runner.get_math_deg())
	rotate_runner.is_ready = true

	if rotate_configure.is_infinite:
		rotate_configure.use_target = false
		return

	var last :float= rotate_configure.last_turn_angle
	if last < 0.0:
		last = rotate_configure.start_deg
	last = _wrap_deg(last)

	var last_seg := _dir_distance(rotate_configure.start_deg, last, rotate_configure.is_clockwise)
	_total_rotate = max(0, rotate_configure.round_num) * 360.0 + last_seg
	rotate_configure.rotate_deg = _total_rotate
	rotate_configure.use_target = true
	super._ready(runner,configure);
	
	
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	if not rotate_runner.is_ready:
		return false

	if rotate_configure.is_infinite or not rotate_configure.use_target:
		var step := _compute_step(999999.0, delta) # remain huge
		var sign := -1.0 if rotate_configure.is_clockwise else 1.0
		rotate_configure.current_deg = _wrap_deg(rotate_configure.current_deg + sign * step)
		rotate_runner.apply_math_deg(rotate_configure.current_deg)
		return true

	# target total rotate
	var remain :float= rotate_configure.rotate_deg - rotate_configure.rotated_deg
	if remain <= rotate_configure.epsilon_deg:
		# snap end
		var sign2 := -1.0 if rotate_configure.is_clockwise else 1.0
		var final_deg := _wrap_deg(rotate_configure.start_deg + sign2 * rotate_configure.rotate_deg)
		rotate_configure.current_deg = final_deg
		rotate_runner.apply_math_deg(final_deg)
		return false

	var step2 := _compute_step(remain, delta)
	var sign3 := -1.0 if rotate_configure.is_clockwise else 1.0
	var actual :float= min(step2, remain)

	rotate_configure.rotated_deg += actual
	rotate_configure.current_deg = _wrap_deg(rotate_configure.current_deg + sign3 * actual)
	rotate_runner.apply_math_deg(rotate_configure.current_deg)
	return true

func _dir_distance(cur: float, target: float, clockwise: bool) -> float:
	if clockwise:
		return fposmod(cur - target, 360.0)
	else:
		return fposmod(target - cur, 360.0)

func _compute_step(remain: float, dt: float) -> float:
	if rotate_configure.acceleration < 0.0 and rotate_configure.deceleration < 0.0:
		return rotate_configure.max_speed_deg * dt

	if rotate_configure.acceleration > 0.0:
		rotate_configure.current_speed_deg = min(rotate_configure.current_speed_deg + rotate_configure.acceleration * dt, rotate_configure.max_speed_deg)
	else:
		rotate_configure.current_speed_deg = rotate_configure.max_speed_deg

	if rotate_configure.deceleration > 0.0:
		var v_stop := sqrt(max(2.0 * rotate_configure.deceleration * remain, 0.0))
		rotate_configure.current_speed_deg = min(rotate_configure.current_speed_deg, v_stop)

	return rotate_configure.current_speed_deg * dt

func _wrap_deg(d: float) -> float:
	return fposmod(d, 360.0)
