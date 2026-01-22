extends Order
class_name Composite_order

@export var sub_orders: Array[Order] = []
@export var end_when_all_done: bool = true  

func _init(cfgs = [Configure],dur:float = -1.0) -> void:
	for cfg in cfgs:
		var order = Order.new(cfg);
		order.setting(cfg,null,dur);
		sub_orders.append(order);


func start(actor, _runner:Task_runner) -> void:
	_elapsed = 0.0
	# do subOrder  init
	for o in sub_orders:

		o.start(actor, _runner)

func update(actor, ai_runner, delta: float) -> bool:
	_elapsed += delta

	var all_done := true
	for o in sub_orders:
		if o == null:
			continue
		var done := o.update(actor, ai_runner, delta)
		if not done:
			all_done = false

	if duration > 0.0 and _elapsed >= duration:
		return true

	if end_when_all_done:
		return all_done

	return false  
func cancel() ->void:
	for o in sub_orders:
		o.cancel();
	
func interrupt() -> void:
	# override
	for o in sub_orders:
		o.interrupt();
