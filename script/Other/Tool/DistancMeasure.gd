# Distance_measure.gd
extends Node
class_name Distance_measure

# 最近的 controller（返回对象本身；空则返回 null）
func get_close_controller(position: Vector2, controllers: Array) -> Object:
	var best :Object= null
	var best_d := INF

	for c in controllers:
		if c == null or (c is Object and not is_instance_valid(c)):
			continue
		var p := _get_pos(c)
		var d := position.distance_to(p)
		if d < best_d:
			best_d = d
			best = c

	return best

# 最远的 controller（你原型叫 get_distance_controller，这里按“最远”实现）
func get_distance_controller(position: Vector2, controllers: Array) -> Object:
	var best :Object= null
	var best_d := -INF
	for c in controllers:
		if c == null or (c is Object and not is_instance_valid(c)):
			continue
		var p := _get_pos(c)
		var d := position.distance_to(p)
		if d > best_d:
			best_d = d
			best = c
	return best

# 范围内的 controllers（<= range）
func get_controllers_in_range(position: Vector2, controllers: Array, range: float) -> Array:
	var out: Array = []
	var r :float= max(range, 0.0)

	for c in controllers:
		if c == null or (c is Object and not is_instance_valid(c)):
			continue
		var p := _get_pos(c)
		if position.distance_to(p) <= r:
			out.append(c)

	return out

func get_distance(position1: Vector2, position2: Vector2) -> float:
	return position1.distance_to(position2)

# 数学角度（y 向上为正）：0°在 +x，逆时针为正
func get_math_deg(start: Vector2, target: Vector2) -> float:
	var dx := target.x - start.x
	var dy := target.y - start.y
	# 数学坐标系：y 向上，所以把屏幕坐标的 dy 反过来
	var rad := atan2(-dy, dx)
	return fposmod(rad_to_deg(rad), 360.0)

# Godot 角度（屏幕坐标）：0°在 +x，逆时针为正（y 向下）
func get_deg(start: Vector2, target: Vector2) -> float:
	var dir := (target - start)
	if dir == Vector2.ZERO:
		return 0.0
	return fposmod(rad_to_deg(dir.angle()), 360.0)

# ---- helpers ----
func _get_pos(c: Object) -> Vector2:
	# 兼容你的 controller duck-typing：get_actor_position()
	if c != null and c.has_method("get_actor_position"):
		return c.call("get_actor_position")
	# 兼容 Node2D
	if c is Node2D:
		return (c as Node2D).global_position
	# 兜底
	if c != null and "global_position" in c:
		return c.global_position
	return Vector2.ZERO

# Pattern helper functions
func angle_deg_to_dir(angle_deg: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(angle_deg)).normalized()

func dir_to_angle_deg(dire: Vector2) -> float:
	return rad_to_deg(dire.angle())

func normalize_angle(angle_deg: float) -> float:
	return fposmod(angle_deg, 360.0)
