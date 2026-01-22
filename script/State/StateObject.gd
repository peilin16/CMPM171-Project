# State_object.gd
extends System
class_name State_object
enum TYPE { SELECTOR, SEQUENCE ,OBJECT}   # 
@export var state_name: String = "Object"
@export var priority: int = 1
@export var can_be_interrupted: bool = true
@export var state_animation: Animation_object
@export var type:TYPE= TYPE.OBJECT;

# default: selector/sequence always want to run if parent asks
func _init(hub: State_hub = null) -> void:
	belong = Belong.STATE;

func trigger(controller) -> bool:
	return false

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	pass
	
func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	pass

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	#if is_done(controller,hub,anim):
	pass

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.playing = false;

# ---- important for Sequence ----
# default: leaf will not done unless overridden
func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return false
