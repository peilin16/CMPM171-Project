
# EnemyController.gd
extends Character_controller
class_name Enemy_controller

# EnemyController.gd
var _logic :enemy_logic;
var _ai_brain_hub: State_hub = null;


#child node2d
#@onready var _caster: caster = $Caster;
#@onready var _spring: Spring = $Spring;
#@onready var _task: Task_runner = $TaskRunner
@onready var scheduler: Scheduler = $Scheduler
@onready var vfx_parser: VFX_parser = $VFXParser
signal enemy_deactivated(enemy);
#@export var config: EnemyConfiguration
var stats: Dictionary = {}

@export var horde_enemy_collision_layer: int = 2
@export var horde_collision_player_range: float = 420.0
@export var horde_separation_player_range: float = 260.0
@export var horde_separation_radius: float = 42.0
@export var horde_separation_strength: float = 0.28

@export var death_gravity: float = 100.0       # how fast enemy falls when dying
@export var death_delay: float = 1.0          # how long it can still be hit after hp <= 0


var death_time: float = 0.0       # death time
var is_spawn:bool = false;

var is_dying:bool = false;



func _init() ->void:
	team = TEAM.ENEMY;
	
func _ready() -> void:
	# Load stats based on name (e.g. "Grunt", "fairy1")
	# Name is usually set in _init of subclass
	if GameManager.enemy_manager:
		stats = GameManager.enemy_manager.get_enemy_stats(name)
		if stats.has("max_hp") and _character:
			_character.max_hp = stats["max_hp"]
			_character.hp = _character.max_hp
	
	#spring
	if _character == null:
		_character = Enemy.new();
	if _logic == null:
		_logic = enemy_logic.new(self, _character);
	#await get_tree().create_timer(0.5).timeout
	if is_spawn == false:
		is_spawn = true;
	_logic.set_up_scheduler(scheduler);
	
	_ai_brain_hub = get_node_or_null("StateHub")
	if _ai_brain_hub and _ai_brain_hub.root_state:
		_ai_brain_hub.root_state.enter(self, _ai_brain_hub, _ai_brain_hub.anim_player)
	#_task._start(_logic.get_queue());
	hitable = true;
	#
	
	#_task._queue = _logic.queue;
	set_collision_layer_value(2, true)
	

func _physics_process(delta: float) -> void:
	rotation = 0.0
	#_spring.update_spring(delta)
	if _character.hp <= 0 :
		death()
		return;
	_update_horde_collision_mode()
		
	if _ai_brain_hub and _ai_brain_hub.root_state:
		_ai_brain_hub.root_state.update(self, _ai_brain_hub, _ai_brain_hub.anim_player, delta)
		if _ai_brain_hub.root_state.is_done(self, _ai_brain_hub, _ai_brain_hub.anim_player):
			_ai_brain_hub.root_state.enter(self, _ai_brain_hub, _ai_brain_hub.anim_player)
			
	# --- normal alive update ---
	#if is_death and hitable and _spring.data.death_elapsed > _spring.data.combo_window:
		#hitable = false   
	#_task._physics_process(delta)	
	
func activate(behavoir_code:String = "")->void:
	is_spawn = true;
	is_death = false;
	hitable = true;
	_set_collision_shapes_disabled(false)
	_character.isActive = true;
	_logic.reset();
	_logic.behavoir = behavoir_code;
	GameManager.enemy_manager.register_active_enemy(controller_id);
	_logic.apply_behavior();
#be spawn
func deactivate()->void:
	is_spawn = false;
	hitable = false;
	GameManager.enemy_manager.unregister_active_enemy(controller_id);
	emit_signal("enemy_deactivated", self);
	
	
func apply_hit_by_float(damage:float):
	if not is_death:
		if damage > 0:
			play_hurt_flash()
		_logic.apply_damage(damage);

func behit(bullet:Bullet):
	if not is_death:
		if bullet and bullet.damage > 0:
			play_hurt_flash()
		_logic.behit(bullet);
	


func death() -> void:
	if is_death:
		return
	
	var level:Level_controller = GameManager.level_manager.current_level;
	if level != null:
		level.widget_spawner.spawn_widget(global_position, 4);
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
	call_deferred("_call_death_delay")

func _call_death_delay() -> void:
	await get_tree().create_timer(max(death_delay, 0.0)).timeout
	if not is_inside_tree():
		return
	hitable = false;          # now bullets should ignore this enemy
	_set_collision_shapes_disabled(true)
	deactivate()

func _set_collision_shapes_disabled(disabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", disabled)

func _get_player_distance() -> float:
	if not GameManager.player_manager or GameManager.player_manager.player == null:
		return INF
	var target: Node2D = GameManager.player_manager.player
	return global_position.distance_to(target.global_position)

func _update_horde_collision_mode() -> void:
	var dist := _get_player_distance()
	var should_collide_enemy := dist <= horde_collision_player_range
	set_collision_mask_value(horde_enemy_collision_layer, should_collide_enemy)

func apply_horde_separation(desired_velocity: Vector2) -> Vector2:
	if desired_velocity.length() <= 0.001:
		return desired_velocity
	if _get_player_distance() > horde_separation_player_range:
		return desired_velocity
	if not GameManager.enemy_manager:
		return desired_velocity

	var active: Dictionary = GameManager.enemy_manager.get_all_active_enemies()
	if active.is_empty():
		return desired_velocity

	var push := Vector2.ZERO
	var count := 0
	for e in active.values():
		if e == null or not is_instance_valid(e):
			continue
		if e == self:
			continue
		if e is not Enemy_controller:
			continue
		var other := e as Enemy_controller
		if other.is_death:
			continue
		var d := global_position.distance_to(other.global_position)
		if d <= 0.001 or d >= horde_separation_radius:
			continue
		var w := 1.0 - (d / horde_separation_radius)
		push += (global_position - other.global_position).normalized() * w
		count += 1

	if count == 0:
		return desired_velocity

	push /= float(count)
	var speed := desired_velocity.length()
	var base_dir := desired_velocity.normalized()
	var blended := (base_dir + push * horde_separation_strength).normalized()
	return blended * speed
