# GenericFairy1Controller.gd
extends Enemy_controller
class_name GenericFairy1Controller

@export var fly_speed := 0;

func _init() ->void:
	_character = Generic_fairy1.new();
	_logic = Generic_fairy1_logic.new(self,_character);
	team = TEAM.ENEMY;

func _ready() -> void:
	super._ready()  #
	print("Generic Fairy 1 ready!");

func _physics_process(delta: float) -> void:
	super._physics_process(delta);
	#var wave := sin(Time.get_ticks_msec() / 400.0) * 40.0
	#apply_central_force(Vector2(0, wave))
