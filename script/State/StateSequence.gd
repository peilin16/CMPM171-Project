
extends State_object
class_name State_sequence


@export var child_states: Array[State_object] = [];

var current_child_index: int = 0
var current_state: State_object
var _finished: bool = false;
var _playing: bool = false;

func _init(hub: State_hub = null) -> void:
	state_name = "Sequence"
	type= TYPE.SEQUENCE;
	
func trigger(controller) -> bool:
	#return controller.want_defence and controller.can_defence()
	if _playing and not _finished:
		return true;
	if current_state and (not current_state.can_be_interrupted and not _finished):
		return true;
	return false;
	
func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	_finished = false
	current_child_index = 0
	if child_states.is_empty():
		_finished = true
		return
	current_state = child_states[current_child_index]
	current_state.enter(controller, hub, anim)
	_playing = true;


func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	if _finished:
		return
	current_state.update(controller, hub, anim, delta)
	if current_state.is_done(controller, hub, anim):
		_require_next(controller, hub, anim)

func _require_next(controller, hub: State_hub, anim: Animation_player) -> void:
	current_state.exit(controller, hub, anim)
	current_child_index += 1
	if current_child_index >= child_states.size():
		_finished = true
		_playing = false;
		return
	current_state = child_states[current_child_index]
	current_state.enter(controller, hub, anim)
	

func append_state(state: State_object, hub: State_hub)-> void:
	child_states.append(state);
	if not hub._state_map.has(state.state_name):
		hub.appand_map(state);
		
func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	current_state = null;
	current_child_index = 0
	_playing = false;
	
	
func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return _finished
