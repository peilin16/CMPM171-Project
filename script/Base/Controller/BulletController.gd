extends Area2D
class_name Bullet_controller



signal bullet_deactivated(bullet);
var bullet:Bullet; # bullet object
var controller_id :int;#id
#@export var texture_path: NodePath
#@export var subsystems_path: NodePath
#@export var taskrunner_path: NodePath

@export var texture_controller:Bullet_texture_controller;

#@onready var subsystems: SubSystemHub = $SubSystemHub  
@onready var scheduler:Scheduler = $Scheduler

#@onready var _state_hub: State_hub = $StateHub;
@onready var sprite: Sprite2D = $BulletSprite
var _dissolving := false;
#vfx
@onready var _vfx: Array[VFX_request];
@onready var vfx_spawner:VFX_controller_spawner = $VFXSpawner
#var task_queue: Array[Order];
var _logic:Bullet_logic;




func _init()->void:
	
	if bullet == null:
		bullet = Bullet.new();
	_logic = Bullet_logic.new(self);	
	_logic.set_up_obj(bullet);
	
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"));
	connect("area_entered", Callable(self, "_on_area_entered"))  
	
	#texture_controller = get_node(texture_path);
	#subsystems= get_node(subsystems_path);
	#_task = get_node(taskrunner_path);
	bullet.is_off_screen = false;
	var notifier = VisibleOnScreenNotifier2D.new();
	add_child(notifier)
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"));
	set_skin();
	_update_collision()
	_logic.set_up_scheduler(scheduler);
	_make_material_unique()

func _on_area_entered(area: Area2D) -> void:
	if not bullet.is_active:
		return;
	#if area.component == Rumia_controller.Component.HEALTHYRANGE:
		#var player := area.get_parent() as Rumia_controller
		#
		#if player.hurtbox.can_hurt:
			#player.behit(bullet);
			#deactivate()
		#
	#elif area.component == Rumia_controller.Component.DEFENCERANGE and area.is_defending:
		#reflect();
	#elif area.component == Rumia_controller.Component.INITIALSHIELD and area.activate:
		#deactivate();
	print(area.name);


func set_skin()->void:
	if texture_controller == null:
		return
	if bullet == null:
		texture_controller.set_skin(0);
	elif bullet.is_red:
		texture_controller.set_skin(1);
	else:
		texture_controller.set_skin(0);
		

#func _set_up_state()->void:
	#_state_hub.appand_map(Idle_state_object.new());
#
#func reflect():
	#bullet.is_reflect = true;
	#bullet.faction = Bullet.Faction.PLAYER
	#_logic.reflect_bullet(movement.get_current_order())
#
	#_update_collision();
	#set_skin();
	
func _on_screen_exited() -> void:
	# if bullet exited screen
	if bullet.is_active:
		bullet.is_off_screen = true
		deactivate()
	
		
func _on_body_entered(body: Node) -> void:
	if not body.hitable:
		return;
		
	if body is Enemy_controller :
		var enemy := body as Enemy_controller
		
		enemy.behit(bullet);
		vfx_spawner.spawn(bullet.explosion_vfx);
		
		deactivate();


func _make_material_unique() -> void:
	if sprite == null:
		return
	if sprite.material:
		sprite.material = sprite.material.duplicate(true)



func start_dissolve_from_global(hit_global: Vector2, duration: float = 0.18) -> void:
	if _dissolving:
		return
	_dissolving = true

	# 立刻关闭碰撞/伤害，避免被重复处理
	monitoring = false
	monitorable = false
	set_physics_process(false)

	# 计算 hit_uv
	var uv := _global_to_sprite_uv(hit_global)
	_set_shader_vec2("hit_uv", uv)
	_set_shader_float("dissolve", 0.0)

	# Tween 推进 dissolve 0->1
	var tw := create_tween()
	tw.tween_method(func(v: float):
		_set_shader_float("dissolve", v)
	, 0.0, 1.0, duration)

	tw.finished.connect(func():
		# 溶解完回收
		deactivate() # 你项目里自己的回池/销毁
	)

func _global_to_sprite_uv(p_global: Vector2) -> Vector2:
	if sprite == null or sprite.texture == null:
		return Vector2(0.5, 0.5)

	var local := sprite.to_local(p_global)

	# Sprite2D centered=true: local 原点在中心；转成左上角空间
	var tex_size := sprite.texture.get_size()
	var s := sprite.scale
	var w := tex_size.x * s.x
	var h := tex_size.y * s.y

	# 如果你有 flip_h/flip_v/region，后面可以再补（先做通）
	var x :float= (local.x + w * 0.5) / max(w, 0.001)
	var y :float= (local.y + h * 0.5) / max(h, 0.001)
	return Vector2(clamp(x, 0.0, 1.0), clamp(y, 0.0, 1.0))

func _set_shader_float(param: String, v: float) -> void:
	var mat := sprite.material
	if mat is ShaderMaterial:
		(mat as ShaderMaterial).set_shader_parameter(param, v)

func _set_shader_vec2(param: String, v: Vector2) -> void:
	var mat := sprite.material
	if mat is ShaderMaterial:
		(mat as ShaderMaterial).set_shader_parameter(param, v)



#func _physics_process(delta: float) -> void:
	##global_position += Vector2.RIGHT * bullet.speed * delta;
	##global_position += bullet.direction * bullet.speed * delta;
	#_task._physics_process(delta);
	
func activate(behavoir_code: String = "")->void:
	GameManager.bullet_manager.register_active_bullet(controller_id);
	#_task._start(task_queue); 
	bullet.is_active = true
	scheduler.start();
	set_skin();
	
func deactivate():
	GameManager.bullet_manager.unregister_active_bullet(controller_id);
	bullet.is_active = false;
	#_task.cancel_all();
	scheduler.cancel();
	_dissolving = false
	if sprite and sprite.material:
		sprite.material.set("shader_parameter/dissolve", 0.0)
	
	emit_signal("bullet_deactivated", self);

func _update_collision() -> void:
	# clear
	collision_layer = 0
	collision_mask = 0
	#pass
	## place in bullet layer
	match bullet.faction:
		bullet.Faction.PLAYER:
			set_collision_layer_value(3, true)  # player_bullet
			set_collision_mask_value(2, true)   # enemy
		bullet.Faction.ENEMY:
			set_collision_layer_value(4, true)  # enemy_bullet
			set_collision_mask_value(5, true)   # player
			set_collision_mask_value(6, true)   # player
			##set_collision_mask_value(5, true)   # environment


# for order system only
func get_actor_position() -> Vector2:
	return global_position

func set_actor_position(p: Vector2) -> void:
	global_position = p

func get_actor_obj() -> Object:
	return bullet;

func get_forward_dir() -> Vector2:
	return bullet.direction   

func is_alive() -> bool:
	return bullet.is_active

func get_id() ->int:
	return controller_id;
func override_data(o) -> void:
	bullet = o;
