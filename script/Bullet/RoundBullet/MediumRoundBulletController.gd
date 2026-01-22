extends Bullet_controller
#blue_medium_round_bullet
class_name  medium_round_bullet_controller

#test
@export var direction: Vector2 = Vector2.RIGHT;



func _init()->void:
	bullet = medium_round_bullet.new();  #object
	super._init();
	
func _ready() -> void:
	super._ready();
	z_index = 8;

#func _physics_process(delta: float) -> void:
	#super._physics_process(delta);
