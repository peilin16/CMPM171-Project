extends Bullet_controller
class_name Mahjong_bullet_controller


#test
@export var direction: Vector2 = Vector2.RIGHT;
@export var runner:Move_runner;

var _current_rad:float = 0;
func _init()->void:
	#bullet = medium_round_bullet.new();  #object
	super._init();
	
func _ready() -> void:
	super._ready();
	#z_index = 8;
	runner = scheduler.get_runner_for(System.Belong.MOVE);

func _physics_process(delta: float) -> void:
	print();
	
	if _current_rad == 0:
		_current_rad = runner.get_data().get_rad()
		rotate(_current_rad);
		#deg_to_rad(_current_deg) ;
