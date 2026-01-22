extends Node
class_name Camera_manager

@export var current_camera: Camera2D

func register_camera(c: Camera2D) -> void:
	current_camera = c

func has_camera() -> bool:
	return current_camera != null and is_instance_valid(current_camera)

# -------- Viewport size (world units) --------
func get_view_size() -> Vector2:
	if not has_camera():
		return Vector2.ZERO

	# viewport 像素尺寸
	var vp_size: Vector2 = current_camera.get_viewport_rect().size
	# 转成世界单位（考虑 zoom：zoom 越大看到越少）
	return vp_size * current_camera.zoom

func get_view_width() -> float:
	return get_view_size().x

func get_view_height() -> float:
	return get_view_size().y

# -------- World rect (visible area in global/world space) --------
func get_view_rect() -> Rect2:
	if not has_camera():
		return Rect2()

	var size := get_view_size()

	# Camera2D 的中心一般就是 global_position（最常用）
	# Godot 4 中 offset 会影响显示中心；我们把 offset 也算进去
	var center := current_camera.global_position + current_camera.offset

	var top_left := center - size * 0.5
	return Rect2(top_left, size)

func get_left_x() -> float:
	return get_view_rect().position.x

func get_right_x() -> float:
	var r := get_view_rect()
	return r.position.x + r.size.x

func get_top_y() -> float:
	return get_view_rect().position.y

func get_bottom_y() -> float:
	var r := get_view_rect()
	return r.position.y + r.size.y

# -------- Contains checks --------
func is_point_in_view(p: Vector2, margin: float = 0.0) -> bool:
	var r := get_view_rect().grow(margin)
	return r.has_point(p)

func is_rect_in_view(rect: Rect2, margin: float = 0.0) -> bool:
	var r := get_view_rect().grow(margin)
	return r.intersects(rect)

func is_node_in_view(node: Node2D, margin: float = 0.0) -> bool:
	if node == null or not is_instance_valid(node):
		return false
	return is_point_in_view(node.global_position, margin)
