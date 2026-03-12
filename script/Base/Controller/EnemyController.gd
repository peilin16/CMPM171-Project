
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
var enemy_type_name: String = ""

@export var horde_separation_radius: float = 24.0
@export var horde_separation_strength: float = 0.4
@export var horde_overlap_radius: float = 14.0
@export var horde_overlap_strength: float = 0.3
@export var horde_velocity_response: float = 8.0

@export var death_gravity: float = 100.0       # how fast enemy falls when dying
@export var death_delay: float = 0.0          # optional corpse linger time after interactions stop


var death_time: float = 0.0       # death time
var is_spawn:bool = false;

var is_dying:bool = false;
var _default_collision_layer: int = 0
var _default_collision_mask: int = 0



func _init() ->void:
	team = TEAM.ENEMY;
	
func _ready() -> void:
	if GameManager.enemy_manager and enemy_type_name != "":
		stats = GameManager.enemy_manager.get_enemy_stats(enemy_type_name)
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
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask
	

func _physics_process(delta: float) -> void:
	rotation = 0.0
	#_spring.update_spring(delta)
	if _character.hp <= 0 :
		death()
		return;
		
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
	is_dying = false;
	hitable = true;
	velocity = Vector2.ZERO
	modulate = Color(1, 1, 1, 1)
	# Kill any leftover hurt-flash tween from previous life
	if _hurt_flash_tween and _hurt_flash_tween.is_running():
		_hurt_flash_tween.kill()
	_restore_collision_state()
	_restore_visual_state()
	_character.isActive = true;
	if stats.is_empty() and enemy_type_name != "" and GameManager.enemy_manager:
		stats = GameManager.enemy_manager.get_enemy_stats(enemy_type_name)
	# Restore HP from stats so pooled enemies keep correct health
	if stats.has("max_hp"):
		_character.max_hp = stats["max_hp"]
		_character.hp = _character.max_hp
	else:
		_character.hp = _character.max_hp
	_logic.reset();
	_logic.behavoir = behavoir_code;
	GameManager.enemy_manager.register_active_enemy(controller_id);
	_logic.apply_behavior();
	# Re-enter AI state machine so pooled enemies behave correctly
	if _ai_brain_hub and _ai_brain_hub.root_state:
		_ai_brain_hub.root_state.enter(self, _ai_brain_hub, _ai_brain_hub.anim_player)


#be spawn
func deactivate()->void:
	is_spawn = false;
	hitable = false;
	velocity = Vector2.ZERO
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
	is_dying = true
	hitable = false
	#hitable = true         
	#_spring.in_death_mode()
	# 1) enemy becomes lighter
	_character.weight = max(_character.weight * 0.3, 0.1)
	velocity = Vector2.ZERO

	# 2) stop AI / task logic
	_stop_runtime_behavior()
	_disable_interactions()

	#add score
	GameManager.player_manager.add_score(_character.death_score);
	
	## 4)  give a small downward push so it starts to fall
	#velocity.y += 20.0
#
	## 5) start coroutine for delayed "true death"
	##    1.5s during which it can still be hit and keep getting impulses
	#await ToolBar.globalDelayCall.delay(_spring.data.combo_window);
	if death_delay <= 0.0:
		deactivate()
		return
	call_deferred("_call_death_delay")

func _call_death_delay() -> void:
	await get_tree().create_timer(max(death_delay, 0.0)).timeout
	if not is_inside_tree():
		return
	deactivate()

func _set_collision_shapes_disabled(disabled: bool) -> void:
	_set_collision_shapes_disabled_recursive(self, disabled)

func _set_collision_shapes_disabled_recursive(node: Node, disabled: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", disabled)
		_set_collision_shapes_disabled_recursive(child, disabled)

func _disable_interactions() -> void:
	collision_layer = 0
	collision_mask = 0
	_set_collision_shapes_disabled(true)

func _restore_collision_state() -> void:
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	_set_collision_shapes_disabled(false)

func _restore_visual_state() -> void:
	_restore_canvas_item_state(self)

func _restore_canvas_item_state(node: Node) -> void:
	if node is CanvasItem:
		var canvas_item := node as CanvasItem
		canvas_item.visible = true
		canvas_item.modulate = Color(1, 1, 1, 1)
	for child in node.get_children():
		_restore_canvas_item_state(child)

func _stop_runtime_behavior() -> void:
	if scheduler:
		scheduler.stop()
		scheduler.cancel()
		scheduler.clear()

func apply_horde_separation(desired_velocity: Vector2, delta: float) -> Vector2:
	# Horde steering should be soft and stable:
	# 1) a small anti-overlap push when enemies are too close
	# 2) mostly lateral flow so packs slide around each other instead of ping-ponging
	# 3) damp toward the target velocity to avoid per-frame twitching
	var current_speed := desired_velocity.length()
	if current_speed <= 0.001:
		return velocity.move_toward(Vector2.ZERO, horde_velocity_response * max(delta, 0.0))
	if not GameManager.enemy_manager:
		return velocity.move_toward(desired_velocity, current_speed * horde_velocity_response * delta)

	var active: Dictionary = GameManager.enemy_manager.get_all_active_enemies()
	if active.is_empty():
		return velocity.move_toward(desired_velocity, current_speed * horde_velocity_response * delta)

	var forward := desired_velocity.normalized()
	var side_axis := Vector2(-forward.y, forward.x)
	var lateral_weight := 0.0
	var overlap_push := Vector2.ZERO
	var neighbor_count := 0

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

		var offset: Vector2 = global_position - other.global_position
		var distance: float = offset.length()
		if distance <= 0.001 or distance >= horde_separation_radius:
			continue

		var away: Vector2 = offset / distance
		var proximity: float = 1.0 - (distance / horde_separation_radius)
		var side_sign: float = sign(away.dot(side_axis))
		if side_sign == 0.0:
			if controller_id < other.controller_id:
				side_sign = -1.0
			else:
				side_sign = 1.0
		lateral_weight += side_sign * proximity
		neighbor_count += 1

		if distance < horde_overlap_radius:
			var overlap_ratio := 1.0 - (distance / horde_overlap_radius)
			overlap_push += away * overlap_ratio

	if neighbor_count == 0:
		return velocity.move_toward(desired_velocity, current_speed * horde_velocity_response * delta)

	var steering: Vector2 = Vector2.ZERO
	var lateral_strength: float = clamp(lateral_weight / float(neighbor_count), -1.0, 1.0)
	steering += side_axis * lateral_strength * current_speed * horde_separation_strength

	if overlap_push.length() > 0.001:
		var overlap_strength: float = min(overlap_push.length(), 1.0)
		steering += overlap_push.normalized() * current_speed * horde_overlap_strength * overlap_strength

	# Never let separation create a backward component; keep forward pressure constant.
	var backward_component: float = steering.dot(forward)
	if backward_component < 0.0:
		steering -= forward * backward_component

	var target_velocity := desired_velocity + steering
	var max_speed := current_speed * 1.15
	if target_velocity.length() > max_speed:
		target_velocity = target_velocity.normalized() * max_speed

	return velocity.move_toward(target_velocity, current_speed * horde_velocity_response * delta)
