# RumiaIdleState.gd
extends State_object
class_name Player_behit_state


func _init(hub: State_hub = null) -> void:
	state_name = "Idle"
	priority = 10
	can_be_interrupted = true
	state_animation = Animation_object.new();
	state_animation.animation_name = "idle"
	state_animation.is_loop = true
	
func trigger(controller) -> bool:
	# default fallback
	return controller.is_death;
#
#func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	#anim.play(state_animation);
	#print(state_name)
#func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	#
	##controller.move(delta)
#
#func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	#return false
