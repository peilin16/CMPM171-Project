# RumiaIdleState.gd
extends State_object
class_name Player_fire_state


var _pending_trigger: bool = false
var selector :State_selector;


var player:Animation_player;
func _init(hub: State_hub = null) -> void:
	state_name = "Fire"
	priority = 4
	can_be_interrupted = true

	state_animation = Animation_object.new()
	state_animation.animation_name = "idle-shooting-left"
	state_animation.is_loop = false

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	if not controller.shoot_requested.is_connected(_on_shoot_requested):
		controller.shoot_requested.connect(_on_shoot_requested)
	player = anim;

func _on_shoot_requested(payload: Dictionary) -> void:
	_pending_trigger = true


func trigger(controller) -> bool:
	if player.current_animation == state_animation and state_animation.is_playing:
		return true;
	if _pending_trigger:
		_pending_trigger = false
		return true
	return false


func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	if selector.prev_state is Player_idle_state:
		pass
	elif  selector.prev_state is Player_move_state:
		pass
	else:
		pass
	anim.play(state_animation);


func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	controller.move(delta)


func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return anim.is_finished()
