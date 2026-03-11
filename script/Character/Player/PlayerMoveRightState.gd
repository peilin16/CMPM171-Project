# RumiaIdleState.gd
extends State_object
class_name Player_move_right_state
func _init(hub: State_hub = null) -> void:
	state_name = "MoveRight"
	priority = 2
	can_be_interrupted = true
	state_animation = Animation_object.new();
	state_animation.animation_name = "right"
	state_animation.is_loop = true
	state_animation.animation_speed = 4
func trigger(controller) -> bool:
	# default fallback
	return controller.move_data.moveX == Move_data.X.RIGHT or controller.move_data.moveY == Move_data.Y.DOWN;

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.play(state_animation);
	#print(state_name)
func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	
	controller.move(delta)

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return controller.move_data.moveX != Move_data.X.RIGHT or controller.move_data.moveY != Move_data.Y.DOWN;
