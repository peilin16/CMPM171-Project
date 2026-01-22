# PatternRunner.gd
extends Runner
class_name Shoot_runner

@export var default_pattern: Shooting_pattern   # default pattern


var _current_pattern: Shooting_pattern = null
var _current_configure: Shoot_configure = null
var container :Node2D;


func _ready() -> void:
	super._ready();
	#controller = get_parent().get_parent() as CharacterController
	container = get_tree().current_scene.get_node("BulletContainer");
# start pattern

func start(actor, pattern: Pattern, configure: Configure) -> void:
	controller = configure.controller;
	
	stop()  # stop old pattern
	if pattern == null or configure == null:
		return
		
	_current_pattern = pattern as Shooting_pattern
	_current_configure = configure as Shoot_configure
	is_running = true;
	_current_pattern._ready(self, _current_configure);
	
	is_finished = false
	


func _physics_process(delta: float) -> void:
	if not is_running  or is_finished:		return
	#if _current_pattern != null:
	is_finished = _current_pattern.play(self, _current_configure, delta);
	if is_finished:
		end();
## default pattern
#func start_default(order: Shoot_configure) -> void:
	#if default_pattern:
		#start(default_pattern, order)
func end()->void:
	_current_pattern.deactive();
	is_finished = true
func stop() -> void:
	if not is_running:
		return
	is_running = false
	# if exist pattern




	
