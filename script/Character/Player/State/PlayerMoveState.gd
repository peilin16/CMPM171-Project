# RumiaIdleState.gd
extends State_object
class_name Player_move_state


var move_data:Move_data;
var current_move:String;
var fire_state:Player_fire_state;
func _init(hub: State_hub = null) -> void:
	state_name = "Move"
	priority = 2
	can_be_interrupted = true
	state_animation = Animation_object.new();
	state_animation.animation_name = "walking-left"
	state_animation.is_loop = true
func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	move_data = controller.move_data;

func trigger(controller) -> bool:
	# default fallback

	return controller.move_data.moveX != Move_data.X.NONE or controller.move_data.moveY != Move_data.Y.NONE;



func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	_modify_anim(anim);
	#print(state_name)

func _get_anim_name()->String:
	if  move_data.moveY == Move_data.Y.TOP:
		match move_data.moveX:
			Move_data.X.LEFT:
				return "walking-left-up";
			Move_data.X.NONE:
				return "walking-up";
			Move_data.X.RIGHT:
				return "walking-right-up"
	elif  move_data.moveY == Move_data.Y.DOWN:
		return "walking-down";
			
	else:
		match move_data.moveX:
			Move_data.X.LEFT:
				return "walking-left";
			Move_data.X.RIGHT:
				return "walking-right"
	return "walking-down";
func _modify_anim(anim: Animation_player)->void:
	current_move= _get_anim_name();
	state_animation.animation_name =current_move
	anim.play(state_animation);

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	if _get_anim_name() != current_move:
		_modify_anim(anim);
	controller.move(delta)

	
	
func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
