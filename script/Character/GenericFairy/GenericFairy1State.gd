extends State_selector
class_name Generic_fairy_1_state


enum Fairy{Fairy1,Fairy2,Fairy3}

var current_texture:int

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	current_state = default_state;
	state_name = "GenericFairyState"
	current_state.enter(controller, hub, anim);
	
func set_up_type(type:int)->void:
	current_texture = type

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:

	var fly_left := Generic_fairy_fly_left_state.new(hub);
	var fly_right := Generic_fairy_fly_right_state.new(hub);
	fly_left.current_texture = current_texture;
	fly_right.current_texture = current_texture;
	append_state(fly_left,hub);
	append_state(fly_right,hub);
	default_state = fly_left;
	current_state = fly_left;


func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	super.update(controller,hub,anim,delta);

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
