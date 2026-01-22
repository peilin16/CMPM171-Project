# RumiaIdleState.gd
extends State_object
class_name Player_idle_state

func _init(hub: State_hub = null) -> void:
	state_name = "Idle"
	priority = 1
	can_be_interrupted = true
	state_animation = Animation_object.new();
	state_animation.animation_name = "rumia_idle"
	state_animation.is_loop = true

func trigger(controller) -> bool:
	# default fallback
	return true

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.play(state_animation);
	print(state_name)
func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	controller.move(delta)

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
