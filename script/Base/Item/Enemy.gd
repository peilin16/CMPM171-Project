extends Character

class_name Enemy
	 
@export var weight: float = 130.0;
#@export var spring_data:Spring_data;

func _init() -> void:
	super._init();
	max_hp = 20
	hp = max_hp
	isEnemy = true;
	#spring_data = Spring_data.new();
	move_data = Move_data.new();
