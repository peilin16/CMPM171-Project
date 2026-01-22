extends Enemy_pool
class_name Generic_fairy_1_pool



func _ready():
	pool_name = "GENERIC_FAIRY_1";

func get_pool_name() -> String:
	return pool_name   # Unique Pool Name
