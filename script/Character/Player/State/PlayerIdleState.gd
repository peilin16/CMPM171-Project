# RumiaIdleState.gd
extends State_object
class_name Player_idle_state


var move_data:Move_data;
var last_move:Player_move_state;
var state_anima_dict :Dictionary = {
	"walking-down":"idle-down",
	"walking-left":"idle-left",
	"walking-right":"idle-right",
	"walking-left-up":"idle-left-up",
	"walking-right-up":"idle-right-up",
	"walking-up":"idle-up",
}


func _init(hub: State_hub = null) -> void:
	state_name = "Idle"
	priority = 1
	can_be_interrupted = true
	state_animation = Animation_object.new();
	state_animation.animation_name = "idle-down"
	state_animation.is_loop = true

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	move_data = controller.move_data;
	
func trigger(controller) -> bool:
	return true

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.play(state_animation);
	#print(state_name)
func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	
	controller.move(delta)

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
