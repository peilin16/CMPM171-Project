# RumiaIdleState.gd
extends State_object
class_name Player_fire_state

var _pending_trigger: bool = false
var player:Animation_player;
var current_target:Vector2;
var selector:State_selector;
func _init(hub: State_hub = null) -> void:
	state_name = "Fire"
	priority = 4
	can_be_interrupted = true

	state_animation = Animation_object.new()
	state_animation.animation_name = "walk-shooting-left"
	state_animation.is_loop = false


func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	if not controller.shoot_requested.is_connected(_on_shoot_requested):
		controller.shoot_requested.connect(_on_shoot_requested)
	player = anim



func _on_shoot_requested(payload: Dictionary) -> void:
	_pending_trigger = true
	current_target = payload["world_pos"]




func trigger(controller) -> bool:
	if player.current_animation == state_animation and not player.is_finished():
		return true;
	if _pending_trigger:
		_pending_trigger = false
		return true
	return false


func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	#if controller.global_position == 
	var deg:float = ToolBar.distanceMeasure.get_math_deg(controller.global_position, current_target);
	if selector.prev_state is Player_idle_state:
		if deg <30 or deg > 330:
			state_animation.animation_name = "idle-shooting-right";
		elif deg >30 and deg < 80:
			state_animation.animation_name = "idle-shooting-right-up";
		elif deg >80 and deg < 100:
			state_animation.animation_name = "idle-shooting-up";
		elif deg >100 and deg < 150:
			state_animation.animation_name = "idle-shooting-left-up";
		elif deg >150 and deg < 210:
			state_animation.animation_name = "idle-shooting-left";
		else:
			state_animation.animation_name = "idle-shooting-down";
	elif selector.prev_state is Player_move_state:
		if deg <30 or deg > 330:
			state_animation.animation_name = "walk-shooting-right";
		elif deg >30 and deg < 80:
			state_animation.animation_name = "walk-shooting-right-up";
		elif deg >80 and deg < 100:
			state_animation.animation_name = "walk-shooting-up";
		elif deg >100 and deg < 150:
			state_animation.animation_name = "walk-shooting-left-up";
		elif deg >150 and deg < 210:
			state_animation.animation_name = "walk-shooting-left";
		else:
			state_animation.animation_name = "walk-shooting-down";

		
	
	anim.play(state_animation)
	

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	controller.move(delta)


func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return anim.is_finished();
