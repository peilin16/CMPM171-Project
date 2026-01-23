# AiTaskRunner.gd
extends Node2D
class_name Task_runner

@export var orders: Array[Order] = []
@onready var subsystems: Sub_action_hub = $SubActionHub 
var runner:Runner;
var _queue: Array[Order] = []
var _current: Order = null
var actor
var _stop:bool = true
var is_done:bool = false;
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
	_stop = false;
	is_done = false;
	if not queue.is_empty(): 
		_queue = queue;
	else:
		return;
	#if not subsystems:
		#subsystems = actor.subsystems;
	_current = _queue.pop_front();
	_current.start(actor, self);

#add order
func add_order(order: Order,index:int = -1 )->void:
	if index == -1:
		_queue.append(order);
	else:
		_queue.insert(index,order);
	


func _physics_process(delta: float) -> void:
	if _stop:
		return;
	if _current == null:
		if _queue.is_empty():
			return
		_current = _queue.pop_front()
		_current.start(actor, self)

	if _current:
		var is_finished := _current.update(actor, self, delta);
		if is_finished:
			_current = null;
		if _queue.is_empty():
			is_done = true;

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
