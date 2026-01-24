# AiTaskRunner.gd
extends Node2D
class_name Task_runner

@export var orders: Array[Order] = []
@onready var subsystems: Sub_action_hub = $SubActionHub 

var _queue: Array[Order] = []
var _current: Order = null
var actor
var _stop:bool = true
var is_current_done:bool = true;
var is_all_done:bool = false;
var runner:Runner;


func _ready() -> void:
	actor = get_parent();
	#subsystems = actor.get_node("SubSystemHub");
	reset_queue()
	
func reset_queue() -> void:
	_queue = orders.duplicate()
	_current = null


func set_runner(r:Runner)->void:
	runner = r;


func get_runner_for(belong: System.Belong) -> Runner:
	if subsystems == null:
		return runner;
	return subsystems.get_runner_for(belong);

func _start(queue: Array[Order] = [] ) ->void:
	is_all_done = false;
	if not queue.is_empty(): 
		_queue.clear()
		
	_queue = queue;
	if _queue.is_empty():
		return
	_stop = false;
	is_current_done = true;
	#if not subsystems:
		#subsystems = actor.subsystems;
	#_current = _queue.pop_front();
	#_current.start(actor, self);

#add order
func add_order(order: Order,index:int = -1 )->void:
	if index == -1:
		_queue.append(order);
	else:
		_queue.insert(index,order);
	


func _physics_process(delta: float) -> void:
	if _stop or is_all_done:
		return;
	if is_current_done:
		if _queue.is_empty():
			return
		_current = _queue.pop_front()
		_current.start(actor, self)

	if _current:
		is_current_done = _current.update(actor, self, delta);
		
		if _queue.is_empty() and is_current_done:
			is_all_done = true;

#cancel all task
func cancel_all() ->void:
	cancel();
	_queue.clear();
	
	
func cancel()->void:
	if _current:
		_current.cancel();
		_current = null;
	
#interrupt
func interrupt() -> void:
	_stop = true;
	if _current:
		_current.interrupt();
