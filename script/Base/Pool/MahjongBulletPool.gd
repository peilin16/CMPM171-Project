extends bullet_pool
class_name Mahjong_bullet_pool



func _ready():
	pool_name = "MAHJONG_BULLET";

func get_pool_name() -> String:
	return pool_name   # Unique Pool Name
