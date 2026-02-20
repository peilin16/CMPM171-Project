extends Enemy
class_name StoneLion

func _init() -> void:
	super._init()
	max_hp = 250
	hp = max_hp
	move_data = Move_data.new()
