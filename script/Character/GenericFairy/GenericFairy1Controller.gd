# GenericFairy1Controller.gd
extends Enemy_controller
class_name GenericFairy1Controller

@export var fly_speed := 0;
@onready var state_hub:State_hub = $StateHub;



var sprite_animation:Array;

func _init() ->void:
	name = "fairy1"
	_character = Generic_fairy1.new();
	_logic = Generic_fairy1_logic.new(self,_character);
	team = TEAM.ENEMY;

func _ready() -> void:
	super._ready()  #
	print("Generic Fairy 1 ready!");
	


func activate(behavoir_code:String = "",sprite_code:int = 0)->void:
	var state := Generic_fairy_1_state.new();
	state.set_up_type(sprite_code)
	state_hub.set_up_root(state);
	super.activate(behavoir_code);
	

func _call_death_delay() -> void:
	vfx_parser.setup(_character.death_vfx_scipt);
	
	super._call_death_delay();
func deactivate()->void:
	#move_data = null;
	super.deactivate()
