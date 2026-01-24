extends Order
class_name Sequence_order

@export var sub_orders: Array[Order] = []
@export var current:Order;
var is_current_done:bool = true;
var is_stop:bool = false
func _init(cfgs:Array =[],dur:float = -1.0) -> void:
	if cfgs.is_empty():
		return;

	for cfg in cfgs:
		var order = Order.new(cfg);
		#order.setting(cfg,null,dur);
		sub_orders.append(order);

func append(order: Order)->void:
	sub_orders.append(order);

func get_current()->Order:
	return current;

func start(actor, _runner:Task_runner) -> void:
	_elapsed = 0.0
	is_stop = false
	# do subOrder  init

func update(actor, ai_runner, delta: float) -> bool:
	if is_stop:
		return false;
	if not sub_orders.is_empty():
		if is_current_done:
			current = sub_orders.pop_front();
			current.start(actor, ai_runner);
		is_current_done = current.update(actor, ai_runner, delta);
		return false;
	else:
		return true;

func cancel() ->void:
	sub_orders.clear();
	#is_stop = true;
	
func interrupt() -> void:
	is_stop = true;
