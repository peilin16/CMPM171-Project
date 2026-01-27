extends State_object
class_name Generic_fairy_fly_right_state

var current_texture:int = 0
func _init(hub: State_hub = null) -> void:
	state_name = "FlySlow"
	priority = 2

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	can_be_interrupted = true
	state_animation = Animation_object.new();
	if current_texture == 0:
		state_animation.animation_name = "fly_right_1"
	elif current_texture == 1:
		state_animation.animation_name = "fly_right_2"
	elif current_texture == 2:
		state_animation.animation_name = "fly_right_3"
	elif current_texture == 3:
		state_animation.animation_name = "fly_right_4"
	else:
		state_animation.animation_name = "fly_right_1"
	state_animation.is_loop = true
	
func trigger(controller) -> bool:
	if controller.move_runner.get_data() == null:
		return false;
	if controller.move_runner.get_data().moveX == Move_data.X.RIGHT:
		return true;
	return false;
		
	#return Input.is_action_pressed("left") #or Input.is_action_pressed("down") or Input.is_action_pressed("up")

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.play(state_animation)
	print(state_name);
	
	
