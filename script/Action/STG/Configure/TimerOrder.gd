extends Order
class_name Timer_order
var _timer: float = 0.0
var delay:float = 0.0
var is_stop:bool = false
func _init(_delay:float) -> void:
	delay = _delay
	_timer = 0;
func set_up_timer(_delay:float) -> void:
	delay = _delay
	_timer = 0;
	
	
func start(actor, _runner:Task_runner) -> void:
	is_stop = false;
func start_timer()->void:
	is_stop = false;

func update(actor, ai_runner, delta: float) -> bool:
	if not is_stop:
		_timer += delta		
	if _timer >= delay:
		return true;
	else:
		return false;
		
func cancel() ->void:
	_timer = 0;
	delay = 0;
	runner = null;
	pattern = null;
	configure = null;
	is_stop = false
func interrupt() -> void:
	# override
	is_stop = true;
