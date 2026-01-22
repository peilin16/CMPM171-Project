extends State_object
class_name State_selector


@export var child_states: Array[State_object] = []

@export var default_state:State_object;
var current_state: State_object
func _init(hub: State_hub = null) -> void:
	state_name = "Selector"
	type= TYPE.SELECTOR;
	

func trigger(controller) -> bool:
	return true;
	#child overwrite


func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	current_state = default_state;
	#child overwrite

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	
	current_state.update(controller, hub, anim, delta)

	var best: State_object = null
	var require_new :bool= false;
	for s in child_states:
		if not s.trigger(controller):
			if s == current_state:
				require_new = true;
			continue
		if best == null or s.priority > best.priority:
			best = s

	if require_new:
		if best == null:
			best = default_state
		_require_state(best, controller, hub, anim)
		return

	if best == current_state:
		return

	if current_state.can_be_interrupted and best.priority > current_state.priority:
		_require_state(best, controller, hub, anim);

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	pass

func append_state(state: State_object, hub: State_hub)-> void:
	child_states.append(state);
	if not hub._state_map.has(state.state_name):
		hub.appand_map(state);

func _require_state(next: State_object, controller, hub: State_hub, anim: Animation_player) -> void:
	if next == null:
		return
	if next == current_state:
		return

	if current_state != null:
		current_state.exit(controller, hub, anim)

	current_state = next
	current_state.enter(controller, hub, anim)
