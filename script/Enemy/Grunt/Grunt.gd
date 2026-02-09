extends Enemy
class_name Grunt

func _init() -> void:
	super._init()
	# Default fallback values
	max_hp = 10
	hp = max_hp
	move_data = Move_data.new() # Ensure move data exists
