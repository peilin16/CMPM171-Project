# Order.gd
extends Resource
class_name Order

@export var pattern: Pattern
@export var configure: Configure
@export var duration: float = -1.0  # <0 =

var _elapsed: float = 0.0

var runner = Runner;

func _init( cfg:Configure = null, _pat:Pattern = null, dur:float = -1.0) -> void:
	if cfg != null:
		setting(cfg , _pat);
	

func setting(con:Configure , _pat:Pattern = null ) -> void:
	pattern = _pat;
	if pattern == null:
		pattern = con.default_pattern();
	configure = con;
	#duration = dur;


func start(actor, _runner:Task_runner) -> void:
	
	_elapsed = 0.0
	#ai_runner._current.
	runner = _runner.get_runner_for(pattern.belong);
	runner.start(actor ,pattern,configure);
	#runner.controller 


func update(actor, ai_runner, delta: float) -> bool:
	_elapsed += delta
	if pattern == null or configure == null:
		return true

	# find Runner
	if runner == null or not runner.is_running:
		return true


	#  on time end
	if duration > 0.0 and _elapsed >= duration:
		return true
		
	if runner.is_finished:
		return true;
	else:
		return false;
		
func cancel() ->void:
	if runner:
		runner.is_finished = true;
		runner.end();
	runner = null;
	pattern = null;
	configure = null;
func interrupt() -> void:
	# override
	if runner:
		runner.is_running = false;
