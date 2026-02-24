extends Node2D
class_name Widget_spawner

@export var radius:float = 24

func spawn_widget(target: Vector2, num: int) -> void:
	if num <= 0:
		return


	var samples_per_widget: int = 8   # 每个widget尝试多少个随机点（越大越分散）
	var min_soft_dist: float = 16.0   # “偏好距离”，越大越不爱靠太近（不是硬性）

	var widgets: Array = PoolManager.widget_pool_manager.spawn_widgets("PowerPointPool", num)

	var placed: Array[Vector2] = []

	for i in range(widgets.size()):
		var wc: Widget_controller = widgets[i]

		var best_offset := Vector2.ZERO
		var best_score := -INF

		for s in range(samples_per_widget):
			var off := _rand_in_circle(radius)

			var score := 0.0
			if placed.size() == 0:
				score = off.length()
			else:
				var min_d := INF
				for p in placed:
					var d := (target + off).distance_to(p)
					if d < min_d:
						min_d = d

				score = min_d + off.length() * 0.15

				if min_d < min_soft_dist:
					score -= (min_soft_dist - min_d) * 2.0

			if score > best_score:
				best_score = score
				best_offset = off

		var pos := target + best_offset
		add_child(wc)

		
		wc.global_position = pos

		placed.append(pos)
		


func _rand_in_circle(radius: float) -> Vector2:
	var r := sqrt(randf()) * radius
	var a := randf() * TAU
	return Vector2(cos(a), sin(a)) * r
