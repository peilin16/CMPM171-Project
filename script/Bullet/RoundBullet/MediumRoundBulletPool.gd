extends bullet_pool
class_name medium_round_bullet_pool



func _ready():
	pool_name = "MEDIUM_ROUND_BULLET";

func get_pool_name() -> String:
	return pool_name   # Unique Pool Name
