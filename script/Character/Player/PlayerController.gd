extends Character_controller
class_name Player_controller

# 获取组件引用
@onready var hurtbox: Area2D = $HurtBox
@onready var vfx_parser: VFX_parser = $VFXParser
@onready var scheduler: Scheduler = $Scheduler
@onready var state_hub: State_hub = $StateHub
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 



# 逻辑与状态变量
@export var logic: Player_logic
var input_vector := Vector2.ZERO
var screen_size: Vector2 
var power_point_num:float;

# 冲刺相关变量
var is_dashing: bool = false
var dash_speed_multiplier: float = 3.0 
var dash_timer: float = 0.0
var dash_duration: float = 0.15 
var dash_cooldown: float = 0.5 
var can_dash: bool = true

# =========================
# Fire rate control
# =========================
@export var base_shoot_cooldown: float = 0.35  # 基础射速（秒）
var shoot_cooldown: float = 0.35              # 实际射速（会被条子加成影响）
var shoot_timer: float = 0.0

# 声明 Move_data 变量
var move_data: Move_data = Move_data.new()

func _resolve_vfx_spawner():
	var node = get_node_or_null("VFXSpawner")
	if node == null:
		node = get_node_or_null("VFXParser/VFXSpawner")
	return node

func _init() -> void:
	_character = Player.new()
	logic = Player_logic.new(self, _character)
	team = TEAM.PLAYER

func _ready() -> void:
	# 1. 获取屏幕大小
	screen_size = get_viewport_rect().size
	
	# 2. 注册玩家
	if GameManager.player_manager:
		GameManager.player_manager.register_player(self)


	# 3. 初始化状态机
	state_hub.set_up_root(Player_state.new())
	
	# 4. 绑定射击事件
	if GameManager.cursor_manager:
		GameManager.cursor_manager.on(GameManager.cursor_manager.EVT_LMB_DOWN, "player_shoot", Callable(self, "player_shooting"))
		
	# 5. 初始化 MoveData (以当前位置为起点)
	move_data.reset(global_position)

func _physics_process(delta: float) -> void:
	# ✅ 每帧更新射击冷却
	if hurtbox.player_hp<= 0:
		death();
		return; 
	
	if shoot_timer > 0.0:
		shoot_timer -= delta

	#print(move_data.moveX);
	handle_fire_mode_hotkeys()
	
	if Input.is_action_just_pressed("Test"):
		SoundManager.command({
		  "sound":"sfx",
		  "name":"cast1",
		  "pitch_scale": 1,
		  "volume_mul":[0.9, 1.05],
		  "timbre_variant" : [0, 4],
		  "priority": 8,
		  "polyphony": 2,
		  "max_voices": 12
		})
		SoundManager.command({
			"sound":"bgm",
			"command":"start",
			"name":"TestBGM1",
			"fade_in":0.2,
			"fade_out":0.7,
			"transfer_fade_out":0.2,
			"use_loop_segment":true,
			"loop_start_sec":12.0,
			"loop_end_sec":48.0,
			"volume_mul":0.5,
			"pitch_scale":1.0
		});
	
	handle_dash_cooldown(delta)

# --- 核心移动逻辑 ---
func move(delta: float, speed: float = _character.player_velocity) -> void:
	
	input_vector = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("avoid") and can_dash and input_vector != Vector2.ZERO:
		start_dash()

	var current_speed = speed
	if is_dashing:
		current_speed *= dash_speed_multiplier
	
	velocity = input_vector * current_speed
	move_and_slide()
	
	#if input_vector.x != 0:
		#animated_sprite.flip_h = input_vector.x < 0
	
	move_data.record_motion(global_position, delta)

# --- 冲刺/闪避系统 ---
func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration

func handle_dash_cooldown(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_timer = dash_cooldown 
	elif !can_dash:
		dash_timer -= delta
		if dash_timer <= 0:
			can_dash = true

# --- 射击系统 ---
func player_shooting(payload: Dictionary) -> void:
	# 当前有效模式（由筒子决定或手动覆盖决定）
	var mode := logic.get_effective_fire_mode()

	# ✅ 只有 MULTI 不吃全局冷却，其它（SINGLE/FAN/RANDOM_FAN）都吃冷却
	if mode != Player_logic.FireMode.MULTI:
		if shoot_timer > 0.0:
			# 调试：你想确认被限制时可以打开这一行
			# print("[Shoot] blocked by cooldown: ", shoot_timer)
			return
		shoot_timer = shoot_cooldown

	var shoot_script: Array = logic.get_shoot_script(payload["world_pos"])
	scheduler.preemption(shoot_script)

func shoot(bullet_script:Array)->void:
	if scheduler.is_running:
		scheduler.preemption(bullet_script)
	else:
		scheduler.setup(bullet_script)
		scheduler.start()

# =========================
# Manual fire mode hotkeys (保留)
# 说明：如果你想“完全由筒子控制”，把 PlayerLogic.gd 里的 manual_fire_mode_override 保持 false 即可
# =========================
func handle_fire_mode_hotkeys() -> void:
	if Input.is_action_just_pressed("fire_mode_1"):
		logic.manual_fire_mode_override = true
		logic.set_fire_mode(Player_logic.FireMode.SINGLE)
		print("[FireMode] MANUAL ", logic.get_fire_mode_name())

	elif Input.is_action_just_pressed("fire_mode_2"):
		logic.manual_fire_mode_override = true
		logic.set_fire_mode(Player_logic.FireMode.FAN)
		print("[FireMode] MANUAL ", logic.get_fire_mode_name())

	elif Input.is_action_just_pressed("fire_mode_3"):
		logic.manual_fire_mode_override = true
		logic.set_fire_mode(Player_logic.FireMode.RANDOM_FAN)
		print("[FireMode] MANUAL ", logic.get_fire_mode_name())

	elif Input.is_action_just_pressed("fire_mode_4"):
		logic.manual_fire_mode_override = true
		logic.set_fire_mode(Player_logic.FireMode.MULTI)
		print("[FireMode] MANUAL ", logic.get_fire_mode_name())


func death()->void:
	if not is_death:
		vfx_parser.execute({
			"name":"Explosion1",
			"life":3,
			"front":true, 
			"scale":0.5
		});#explosion1
		SoundManager.command({
				"sound":"sfx",
			  "name":"explosion1",
			  "pitch_scale": 1,
			  "volume_mul":[0.4, 1.05],
			  "timbre_variant" : [0, 4],
			  "priority": 9,
			  "polyphony": 2,
			  "max_voices": 12
			});
		is_death = true;
		await ToolBar.globalDelayCall.delay(2);
		get_tree().change_scene_to_file("res://scenes/UI/GameOverMenu.tscn")
	
