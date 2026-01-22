# PatternRunner.gd
extends Node2D
class_name Runner

#parent controller bullet or character
#action method only
var controller; 
var is_running: bool = false;
var is_finished: bool = true
var is_ready: bool = false
func _ready() -> void:
	pass
	#controller = get_parent()  #get parent controller
	
#start
func start(actor ,pattern: Pattern, configure: Configure) -> void:
	controller = actor;

#overload start function, it remove pattern parameter
func activate(actor, configure: Configure)-> void:
	pass	
#stop
func stop() -> void:
	pass
func end() ->void:
	pass
#process
func _physics_process(delta: float) -> void:
	pass
