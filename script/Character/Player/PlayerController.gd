extends Character_controller
class_name Player_controller

# 获取组件引用
@onready var hurtbox: Area2D = $HurtBox
@onready var vfx_parser: VFX_spawner = $VFXSpawner
@onready var scheduler: Scheduler = $Scheduler
@onready var state_hub: State_hub = $StateHub
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 

# 逻辑与状态变量
@export var logic: Player_logic
var input_vector := Vector2.ZERO
var screen_size: Vector2 

# 冲刺相关变量
var is_dashing: bool = false
var dash_speed_multiplier: float = 3.0 
var dash_timer: float = 0.0
var dash_duration: float = 0.15 
var dash_cooldown: float = 0.5 
var can_dash: bool = true

# --- 射击控制变量 ---
var shoot_timer: float = 0.0
@export var base_shoot_interval: float = 0.5 # 基础射速
# -----------------

# 声明 Move_data 变量
var move_data: Move_data = Move_data.new()

func _init() -> void:
	# 这里调用 Player.new() 时，会自动执行 Player.gd 里的 _init()，从而获得作弊麻将
	_character = Player.new()
	logic = Player_logic.new(self, _character)
	team = TEAM.PLAYER

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	if GameManager.player_manager:
		GameManager.player_manager.register_player(self)
	
	state_hub.set_up_root(Player_state.new())
	
	# 注意：如果你之前绑定了 cursor_manager 的点击事件，请务必注释掉，否则会和自动连发冲突
	# if GameManager.cursor_manager:
	# 	GameManager.cursor_manager.on(...)
	
	move_data.reset(global_position)
	print("PlayerController Ready. 基础射击间隔: ", base_shoot_interval)

func _physics_process(delta: float) -> void:
	handle_dash_cooldown(delta)
	# 每帧处理射击（实现按住连发）
	handle_shooting(delta)

# --- 核心射击逻辑 ---
func handle_shooting(delta: float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
	
	# 检测鼠标左键是否按住
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if shoot_timer <= 0:
			perform_auto_shoot()

func perform_auto_shoot() -> void:
	var target_pos = get_global_mouse_position()
	
	# 获取攻速加成 (从 _character 数据中读取)
	var speed_multiplier = 1.0
	if _character and _character.has_method("get_attack_speed_multiplier"):
		speed_multiplier = _character.get_attack_speed_multiplier()
	
	# 应用攻速公式：间隔 = 基础间隔 / 倍率
	# 比如倍率是 1.5，间隔就是 0.2 / 1.5 = 0.133秒
	shoot_timer = base_shoot_interval / speed_multiplier
	
	# 执行射击
	var shoot_script: Array = logic.get_shoot_script(target_pos)
	shoot(shoot_script)

# --- 移动逻辑 ---
func move(delta: float, speed: float = _character.player_velocity) -> void:
	input_vector = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("avoid") and can_dash and input_vector != Vector2.ZERO:
		start_dash()

	var current_speed = speed
	if is_dashing:
		current_speed *= dash_speed_multiplier
	
	velocity = input_vector * current_speed
	move_and_slide()
	global_position = global_position.clamp(Vector2.ZERO, screen_size)
	
	if input_vector.x != 0:
		animated_sprite.flip_h = input_vector.x < 0
	
	move_data.record_motion(global_position, delta)

# --- 冲刺系统 ---
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

# --- 兼容旧接口 ---
func player_shooting(payload: Dictionary) -> void:
	var shoot_script: Array = logic.get_shoot_script(payload["world_pos"])
	shoot(shoot_script)

func shoot(bullet_script: Array) -> void:
	scheduler.preemption(bullet_script)