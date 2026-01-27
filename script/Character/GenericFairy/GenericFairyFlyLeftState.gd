extends State_object
class_name Generic_fairy_fly_left_state

var current_texture:int = 0

func _init(hub: State_hub = null) -> void:
	state_name = "FlySlow"
	priority = 2

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	can_be_interrupted = true
	state_animation = Animation_object.new();
	if current_texture == 0:
		state_animation.animation_name = "fly_left_1"
	elif current_texture == 1:
		state_animation.animation_name = "fly_left_2"
	elif current_texture == 2:
		state_animation.animation_name = "fly_left_3"
	elif current_texture == 3:
		state_animation.animation_name = "fly_left_4"
	else:
		state_animation.animation_name = "fly_left_1"
	state_animation.is_loop = true
	state_animation.animation_speed = 1.5
func trigger(controller) -> bool:
	if controller.move_runner.get_data() == null:
		return true;
	elif controller.move_runner.get_data().moveX == Move_data.X.LEFT:
		return true;
	return false;
		
	#return Input.is_action_pressed("left") #or Input.is_action_pressed("down") or Input.is_action_pressed("up")

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.play(state_animation)
	print(state_name);
	
	
