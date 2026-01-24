
# EnemyController.gd
extends Character_controller
class_name Enemy_controller

# EnemyController.gd
var _logic :enemy_logic;


#child node2d
#@onready var _caster: caster = $Caster;
#@onready var _spring: Spring = $Spring;
#@onready var _task: Task_runner = $TaskRunner
@onready var scheduler: Scheduler = $Scheduler
@onready var vfx_parser: VFX_parser = $VFXParser
#@onready var widget_spawner: Widget_spawner = $WidgetSpawner;
@export var death_gravity: float = 100.0       # how fast enemy falls when dying
@export var death_delay: float = 1.0          # how long it can still be hit after hp <= 0


var death_time: float = 0.0       # death time
var is_spawn:bool = false;

var is_dying:bool = false;



func _init() ->void:
	team = TEAM.ENEMY;
	
func _ready() -> void:
	#spring
	if _character == null:
		_character = Enemy.new();
	if _logic == null:
		_logic = enemy_logic.new(self, _character);
	await get_tree().create_timer(0.5).timeout
	if is_spawn == false:
		is_spawn = true;
	_logic.set_up_scheduler(scheduler);
	#_task._start(_logic.get_queue());
	hitable = true;
	#
	_logic.apply_behavior();
	#_task._queue = _logic.queue;
	

func _physics_process(delta: float) -> void:
	#_spring.update_spring(delta)
	if _character.hp <= 0 :
		death()
		return;
	# --- normal alive update ---
	#if is_death and hitable and _spring.data.death_elapsed > _spring.data.combo_window:
		#hitable = false   
	#_task._physics_process(delta)	
	
func activate(behavoir_code:String = "")->void:
	is_spawn = true;
	_character.isActive = true;
	_logic.reset();
	_logic.behavoir = behavoir_code;
	GameManager.enemy_manager.register_active_enemy(controller_id);
	
#be spawn
func deactivate()->void:
	is_spawn = false;
	GameManager.enemy_manager.unregister_active_enemy(controller_id);

func apply_hit_by_float(damage:float):
	if not is_death:
		_logic.apply_damage(damage);

func behit(bullet:Bullet):
	if not is_death:
		_logic.behit(bullet);
		


func death() -> void:
	if is_death:
		return
	#spawn score;
	#widget_spawner.spawn_widget(Widget_request.new("PowerPoint"));
		
	GameManager.enemy_manager.unregister_active_enemy(controller_id);
	is_death = true
	#hitable = true         
	#_spring.in_death_mode()
	# 1) enemy becomes lighter
	_character.weight = max(_character.weight * 0.3, 0.1)

	# 2) stop AI / task logic
	
	scheduler.cancel();


	## 4)  give a small downward push so it starts to fall
	#velocity.y += 20.0
#
	## 5) start coroutine for delayed "true death"
	##    1.5s during which it can still be hit and keep getting impulses
	#await ToolBar.globalDelayCall.delay(_spring.data.combo_window);
	_call_death_delay()

func _call_death_delay() -> void:
	#await get_tree().create_timer(death_delay).timeout
	hitable = false;          # now bullets should ignore this enemy

	# optional: disable collisions to be safe
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
