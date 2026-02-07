extends Enemy
class_name GruntPlus

func _init() -> void:
	super._init()
	max_hp = 30
	hp = max_hp
	move_data = Move_data.new()
