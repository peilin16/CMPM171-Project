extends State_selector
class_name Player_state


func trigger(controller) -> bool:
	return true;
	#child overwrite


func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	current_state = default_state;
	state_name = "PlayerState"

#taskrunner 

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	var idle := Player_idle_state.new(hub);
<<<<<<< Updated upstream
	var move_left := Player_move_left_state.new(hub);
	var move_right := Player_move_right_state.new(hub);
=======
	#var move_left := Player_move_left_state.new(hub);
	var move_state := Player_move_state.new(hub);
	var fire := Player_fire_state.new(hub);
	fire.selector = self;
	idle.last_move = move_state;
	#var move_right := Player_move_right_state.new(hub);
>>>>>>> Stashed changes
	var behit := Player_behit_state.new(hub);
	#var spell:= Luna_scraper_state.new(hub);
	append_state(idle,hub);
	
<<<<<<< Updated upstream
	append_state(move_left,hub);
	append_state(move_right,hub);
=======
	append_state(move_state,hub);
	append_state(fire,hub);
>>>>>>> Stashed changes
	append_state(behit,hub);
	#append_state(spell,hub);
	default_state = idle;
	current_state = idle;
	
	
	
func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	super.update(controller,hub,anim,delta);

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
