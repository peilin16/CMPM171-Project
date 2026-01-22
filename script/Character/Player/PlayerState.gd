extends State_selector
class_name Player_state


func trigger(controller) -> bool:
	return true;
	#child overwrite


func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	current_state = default_state;
	state_name = "RumiaState"

	


func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	var idle := Player_idle_state.new(hub);
	#var fly_slow := Rumia_fly_slow_state.new(hub);
	#var defence := Rumia_twirl_state.new(hub);
	#var redeploy := Rumia_redeploy_sequence.new(hub);
	#var spell:= Luna_scraper_state.new(hub);
	append_state(idle,hub);
	#append_state(fly_slow,hub);
	#append_state(defence,hub);
	#append_state(redeploy,hub);
	#append_state(spell,hub);
	default_state = idle;
	current_state = idle;
	
	
	
func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	super.update(controller,hub,anim,delta);

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
