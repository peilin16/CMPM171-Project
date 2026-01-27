extends Node
class_name Predicting_move

# 返回一个方向向量（normalized），用于 bullet 朝向
# 若无法预测（例如子弹太慢追不上），就返回直指目标当前位置的方向
static func get_intercept_dir(
	shooter_pos: Vector2,
	bullet_speed: float,
	target_pos: Vector2,
	target_vel: Vector2
) -> Vector2:
	if bullet_speed <= 0.0:
		return (target_pos - shooter_pos).normalized()

	var r: Vector2 = target_pos - shooter_pos

	# 解 |r + v*t|^2 = (s*t)^2
	# (v·v - s^2) t^2 + 2(r·v) t + (r·r) = 0
	var a: float = target_vel.dot(target_vel) - bullet_speed * bullet_speed
	var b: float = 2.0 * r.dot(target_vel)
	var c: float = r.dot(r)

	var t: float = -1.0

	if abs(a) < 0.000001:
		# 退化为线性：b*t + c = 0
		if abs(b) < 0.000001:
			# 目标就在枪口 or 完全不可解 -> 直指
			return r.normalized()
		t = -c / b
	else:
		var disc: float = b*b - 4.0*a*c
		if disc < 0.0:
			return r.normalized() # 无实数解：追不上
		var sqrt_disc := sqrt(disc)

		# 两个解取 “最小的正时间”
		var t1 := (-b - sqrt_disc) / (2.0 * a)
		var t2 := (-b + sqrt_disc) / (2.0 * a)

		t = _min_positive(t1, t2)

	if t <= 0.0:
		return r.normalized()

	var hit_pos := target_pos + target_vel * t
	var dir := (hit_pos - shooter_pos)
	if dir.length_squared() <= 0.000001:
		return r.normalized()
	return dir.normalized()


static func _min_positive(t1: float, t2: float) -> float:
	var p1 := t1 > 0.0
	var p2 := t2 > 0.0
	if p1 and p2:
		return min(t1, t2)
	if p1:
		return t1
	if p2:
		return t2
	return -1.0


# 从 Move_data 转成目标速度向量
static func vel_from_move_data(md: Move_data) -> Vector2:
	if md == null:
		return Vector2.ZERO
	var deg := md.get_deg()
	var spd := md.get_speed()
	# 你项目里 deg 是用 Vector2.angle() 记录的，跟 RIGHT.rotated() 是一致的
	return Vector2.RIGHT.rotated(deg_to_rad(deg)) * spd


# 如果你想直接拿角度（deg）
static func get_intercept_deg(
	shooter_pos: Vector2,
	bullet_speed: float,
	target_pos: Vector2,
	target_vel: Vector2
) -> float:
	var dir := get_intercept_dir(shooter_pos, bullet_speed, target_pos, target_vel)
	return rad_to_deg(dir.angle())
