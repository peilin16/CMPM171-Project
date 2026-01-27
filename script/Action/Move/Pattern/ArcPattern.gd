# ArcMovePattern.gd
extends Move_pattern
class_name Arc_move_pattern

var _elapsed := 0.0
var _current_speed := 0.0
var _moved_len := 0.0

var _p0: Vector2
var _p1: Vector2
var _p2: Vector2

var _ts: PackedFloat32Array
var _lens: PackedFloat32Array
var _total_len := 0.0

var _last_tangent := Vector2.RIGHT
var _continue_linear := false

func _ready(runner: Runner, configure: Configure) -> void:
	super._ready(runner, configure)
	move_runner = runner as Move_runner

	var cfg := configure as Arc_move_configure
	if cfg == null:
		runner.is_ready = true
		return

	_elapsed = 0.0
	_current_speed = 0.0
	_moved_len = 0.0
	_continue_linear = false

	_p0 = cfg.start
	_p2 = cfg.target
	_p1 = _compute_vertex(cfg, _p0, _p2)

	_build_lut(cfg.sample_count);
	record.reset(cfg.start);
	runner.is_ready = true


func play(runner: Runner, configure: Configure, delta: float) -> bool:
	var r := move_runner
	if r == null or r.controller == null:
		return true

	var cfg := configure as Arc_move_configure
	if cfg == null:
		return true

	_elapsed += delta



	# 已经切到 continue-linear（到达目标后继续）
	if _continue_linear:
		return _play_continue_linear(cfg, delta)

	# 1) speed update
	_current_speed = _update_speed_arc(cfg, delta)

	# clamp
	_current_speed = clamp(_current_speed, 0.0, cfg.max_velocity)

	# 2) advance distance
	_moved_len += _current_speed * delta

	# 3) reached end?
	if _moved_len >= _total_len - cfg.arrive_epsilon:
		if cfg.is_continue:
			# 固定到终点，拿末端切线当 continue 方向
			r.controller.set_actor_position(_p2);
			record.record_motion(_p2,delta);
			_last_tangent = _bezier_tangent(1.0).normalized()
			_continue_linear = true
			# 继续移动不结束
			#_record_state(_last_tangent, 0.0, 0.0) # 到达那一帧可选
			return false
		else:
			
			r.controller.set_actor_position(_p2)
			record.record_motion(_p2,delta);
			return true

	# 4) len -> t
	var t := _len_to_t(_moved_len)

	# 5) position
	var pos := _bezier_point(t)
	r.controller.set_actor_position(pos)
	record.record_motion(pos,delta);
	# 6) record
	var tan := _bezier_tangent(t).normalized()
	_last_tangent = tan
	#_record_state(tan, _current_speed, _current_speed * delta)

	return false


func _play_continue_linear(cfg: Arc_move_configure, dt: float) -> bool:
	var r := move_runner
	var dir := _last_tangent
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT

	# continue 时：按当前速度继续（你也可以选择锁到 max_velocity）
	_current_speed = _update_speed_linear(cfg, dt)
	_current_speed = clamp(_current_speed, 0.0, cfg.max_velocity)

	var offset := dir * _current_speed * dt
	var pos := r.get_actor_position() + offset
	r.controller.set_actor_position(pos)
	#record.set_direction(pos);
	record.record_motion(pos,dt);
	#_record_state(dir, _current_speed, offset.length())
	return false


func _update_speed_arc(cfg: Arc_move_configure, dt: float) -> float:
	# 没有加减速：直接 max
	if cfg.acceleration < 0.0 and cfg.deceleration < 0.0:
		return cfg.max_velocity

	var v := _current_speed

	# 加速
	if cfg.acceleration >= 0.0 and v < cfg.max_velocity:
		v += cfg.acceleration * dt

	# 减速（建议：接近终点按剩余距离触发）
	if cfg.deceleration >= 0.0:
		var remain :float= max(_total_len - _moved_len, 0.0)
		# 一个朴素阈值：用 “刹车距离 ~= v^2/(2a)” 判断是否该减速
		var brake_dist :float= (v * v) / max(2.0 * cfg.deceleration, 0.001)
		if remain <= brake_dist:
			v -= cfg.deceleration * dt

	return v


func _update_speed_linear(cfg: Arc_move_configure, dt: float) -> float:
	# continue-linear 也复用同样逻辑（你想更简单：return cfg.max_velocity）
	if cfg.acceleration < 0.0 and cfg.deceleration < 0.0:
		return cfg.max_velocity

	var v := _current_speed
	if cfg.acceleration >= 0.0 and v < cfg.max_velocity:
		v += cfg.acceleration * dt
	# linear continue 一般不需要 decel，这里先不减
	return v


func _compute_vertex(cfg: Arc_move_configure, p0: Vector2, p2: Vector2) -> Vector2:
	if cfg.vertex != Vector2.ZERO:
		return cfg.vertex

	var mid := (p0 + p2) * 0.5
	var dir := (p2 - p0)
	if dir == Vector2.ZERO:
		return mid

	var perp := Vector2(-dir.y, dir.x).normalized()
	# auto_height 往“上”弯；auto_side 可做左右偏
	return mid + perp * cfg.auto_height + dir.normalized() * cfg.auto_side


func _build_lut(n: int) -> void:
	n = max(n, 10)
	_ts = PackedFloat32Array()
	_lens = PackedFloat32Array()
	_ts.resize(n + 1)
	_lens.resize(n + 1)

	_total_len = 0.0
	var prev := _bezier_point(0.0)

	_ts[0] = 0.0
	_lens[0] = 0.0

	for i in range(1, n + 1):
		var t := float(i) / float(n)
		var p := _bezier_point(t)
		_total_len += p.distance_to(prev)
		_ts[i] = t
		_lens[i] = _total_len
		prev = p


func _len_to_t(s: float) -> float:
	if s <= 0.0:
		return 0.0
	if s >= _total_len:
		return 1.0

	# 线性扫描也能用；这里用二分更稳
	var lo := 0
	var hi := _lens.size() - 1
	while lo < hi:
		var mid := (lo + hi) >> 1
		if _lens[mid] < s:
			lo = mid + 1
		else:
			hi = mid

	var i :int= max(lo, 1)
	var l0 := _lens[i - 1]
	var l1 := _lens[i]
	var t0 := _ts[i - 1]
	var t1 := _ts[i]
	var u :float= (s - l0) / max(l1 - l0, 0.0001)
	return lerp(t0, t1, u)

#func get_direction(offset:Vector2)->void:
	#record.set_direction(offset);
	
func _bezier_point(t: float) -> Vector2:
	var u := 1.0 - t
	return u*u*_p0 + 2.0*u*t*_p1 + t*t*_p2


func _bezier_tangent(t: float) -> Vector2:
	# derivative of quadratic bezier
	return 2.0*(1.0 - t)*(_p1 - _p0) + 2.0*t*(_p2 - _p1)


#func _record_state(dir: Vector2, speed: float, moved: float) -> void:
	#if record == null:
		#return
	#record.set_speed(speed)
	#if dir != Vector2.ZERO:
		#record.set_deg(rad_to_deg(dir.angle()))
	#record.moved_distance += moved
	
