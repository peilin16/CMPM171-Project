extends Enemy_pool
class_name GruntPlusPool

func _ready() -> void:
	pool_name = "GruntPlus"
	if preload_count > 0:
		preload_enemies(preload_count)
