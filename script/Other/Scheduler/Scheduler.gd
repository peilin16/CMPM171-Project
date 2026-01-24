# Caster.gd
extends Node2D
class_name Scheduler

@onready var task_runner: Task_runner = $TaskRunner
#@onready var shoot_runner :Shoot_runner = $ShootRunner
var parent_controller#: Character_controller
var current_configure = null


var _script: Array = []
var _built_queue: Array[Order] = []


var cast_parser :Cast_parser
var move_parser:Movement_parser
var rotate_parser: Rotate_parser


func _ready() -> void:
	parent_controller = get_parent()# as Character_controller
	#task_runner.set_runner(runner);	
	cast_parser = Cast_parser.new(parent_controller);
	move_parser = Movement_parser.new(parent_controller);
	rotate_parser = Rotate_parser.new(parent_controller);
	
func setup(script: Array) -> void:
	_script = script#.duplicate(true)
	_built_queue = _build_queue_from_script(_script)

func start() -> void:
	if _built_queue.is_empty():
		return
	task_runner._start(_built_queue)

func stop() -> void:
	if task_runner:
		task_runner.stop() 



# task preemption will cancel the current task
func preemption(script: Array)->void:
	if _built_queue.is_empty() and task_runner._current == null:
		setup(script);
	cancel();
	setup(script);
	start();


func get_current_order()->Order:
	return task_runner._current;

func cancel() -> void:
	
	if task_runner:
		task_runner.cancel() # 

func clear() -> void:
	_script.clear()
	_built_queue.clear()
	current_configure = null

func is_stop()->bool:
	return task_runner._stop

func is_finish()->bool:
	return task_runner.is_done;

#Crucial Code: Shoot Parser

func _build_queue_from_script(script: Array) -> Array[Order]:
	var q: Array[Order] = []
	for step in script:
		q.append(_build_order(step))
	return q

func _build_order(step:Dictionary)->Order:
	var order :Order;
	match step.get("parser",step.get("action","") ):
		"timer","delay":
			order = _make_timer_order(step.get("sec", 0.0))
		"cast","shoot":
			order = cast_parser.build_orders_from_step(step);
		"move","movement":
			order = move_parser.build_orders_from_step(step)
		"rotate","round":
			order = rotate_parser.build_orders_from_step(step)
		"composite","synchronous":
			order = _make_composite_order(step);
		"sequence","list":
			order = _make_sequence_order(step);
	return order;

func _make_sequence_order(step: Dictionary)->Order:
	var order:Sequence_order = Sequence_order.new();
	var array:Array = step.get("array", step.get("orders", []))
	for i in array:
		var sub_order:Order = _build_order(i);
		order.append(sub_order)
	return order;
	
	
func _make_composite_order(step: Dictionary)->Order:
	var order:Composite_order = Composite_order.new();
	var array:Array = step.get("array", step.get("orders", []))
	for i in array:
		var sub_order:Order = _build_order(i);
		order.append(sub_order)
	return order;
	

func _make_timer_order(sec: float) -> Order:
	var o :Timer_order = Timer_order.new(sec);
	return o



func get_actor_obj() -> Object:
	return parent_controller.get_actor_obj();

#for order system only
func get_actor_position() -> Vector2:
	return parent_controller.global_position

func set_actor_position(p: Vector2) -> void:
	parent_controller.global_position = p

func get_id() ->int:
	return parent_controller.controller_id;
