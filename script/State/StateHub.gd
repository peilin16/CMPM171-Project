# State_hub.gd
extends Node2D
class_name State_hub

var _controller
#@export var states: Array[State_object] = []   
@export var root_state_name: String = "Root"
@export var root_state:State_object = null;
var _state_map: Dictionary = {}  # name -> StateObject
#var null_state: State_object
@onready var anim_player: Animation_player = $AnimationPlayer


func _ready() -> void:
	_controller = get_parent();

		
	
func appand_map(obj:State_object)->void:
	if _state_map.size() == 0:
		root_state_name = obj.state_name;
		root_state = obj;
	_state_map[obj.state_name]= obj;
	obj.on_ready(_controller,self,anim_player);
	

func _build_state_map(states: Array[State_object] ) -> void:
	if _state_map.size() == 0:
		root_state_name = states[0].state_name;
		root_state = states[0];
	for s in states:
		_state_map[s.state_name] = s
		s.on_ready(_controller,self,anim_player);


func set_up_root(obj:State_object)->void:
	if not _state_map.is_empty():
		_state_map.clear();
	root_state_name = obj.state_name;
	if obj is State_selector:
		root_state =  obj as State_selector
	elif obj is State_sequence:
		root_state = obj as State_sequence
	else:
		root_state = obj
	_state_map[obj.state_name]= obj;
	root_state.on_ready(_controller,self,anim_player);
	root_state.enter(_controller, self, anim_player);
	


func _physics_process(delta: float) -> void:
	if root_state:
		root_state.update(_controller, self, anim_player, delta);

#search state obj
func request_state(name: String) -> State_object:
	return _state_map[name];
