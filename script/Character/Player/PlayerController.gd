extends Character_controller
class_name Player_controller

# 获取组件引用
@onready var hurtbox: Area2D = $HurtBox
@onready var vfx_parser: VFX_spawner = $VFXSpawner
@onready var scheduler: Scheduler = $Scheduler
@onready var state_hub: State_hub = $StateHub
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # 确保你场景里有这个节点

# 逻辑与状态变量
@export var logic: Player_logic
var input_vector := Vector2.ZERO
var screen_size: Vector2 # 用于存储屏幕大小

# 冲刺相关变量
var is_dashing: bool = false
var dash_speed_multiplier: float = 3.0 # 冲刺时速度翻3倍
var dash_timer: float = 0.0
var dash_duration: float = 0.15 # 冲刺持续时间
var dash_cooldown: float = 0.5 # 冲刺冷却时间
var can_dash: bool = true

func _init() -> void:
	# 初始化角色数据和逻辑
	_character = Player.new()
	logic = Player_logic.new(self, _character)
	team = TEAM.PLAYER

func _ready() -> void:
	# 获取屏幕大小，用于限制移动范围
	screen_size = get_viewport_rect().size
	
	# 注册玩家到管理器
	if GameManager.player_manager:
		GameManager.player_manager.register_player(self)
	
	# 初始化状态机
	state_hub.set_up_root(Player_state.new())
	
	# 绑定射击事件 (鼠标左键)
	if GameManager.cursor_manager:
		GameManager.cursor_manager.on(GameManager.cursor_manager.EVT_LMB_DOWN, "player_shoot", Callable(self, "player_shooting"))

func _physics_process(delta: float) -> void:
	# Godot 建议在 physics_process 中处理物理移动
	# 状态机会调用 move()，但为了保险，我们也可以在这里处理冲刺计时
	handle_dash_cooldown(delta)

# --- 核心移动逻辑 ---
func move(_delta: float, speed: float = _character.player_velocity) -> void:
	# 1. 获取输入方向 (归一化防止斜向移动变快)
	input_vector = Input.get_vector("left", "right", "up", "down")
	
	# 2. 处理冲刺逻辑 (检测 Space 键)
	if Input.is_action_just_pressed("avoid") and can_dash and input_vector != Vector2.ZERO:
		start_dash()

	# 3. 计算最终速度
	var current_speed = speed
	if is_dashing:
		current_speed *= dash_speed_multiplier
	
	velocity = input_vector * current_speed
	
	# 4. 执行移动
	move_and_slide()
	
	# 5. 屏幕边缘限制 (Clamp) - 这一步非常重要！
	global_position = global_position.clamp(Vector2.ZERO, screen_size)
	
	# 6. 处理动画 (简单的左右翻转)
	if input_vector.x != 0:
		animated_sprite.flip_h = input_vector.x < 0

# --- 冲刺/闪避系统 ---
func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	# 这里可以播放冲刺音效或特效，比如:
	# vfx_parser.spawn_vfx("dash_effect", global_position) 

func handle_dash_cooldown(delta: float) -> void:
	# 处理冲刺持续时间
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_timer = dash_cooldown # 进入冷却阶段
	
	# 处理冷却时间
	elif !can_dash:
		dash_timer -= delta
		if dash_timer <= 0:
			can_dash = true

# --- 射击系统 ---
func player_shooting(payload: Dictionary) -> void:
	# 1. 获取子弹脚本
	var shoot_script: Array = logic.get_shoot_script(payload["world_pos"])
	# 2. 调用通用射击接口
	shoot(shoot_script)

func shoot(bullet_script: Array) -> void:
	# 3. 直接调用 Scheduler 的抢占模式 (Preemption)
	# Scheduler.gd 中定义了 preemption，它会自动取消当前任务并执行新任务
	scheduler.preemption(bullet_script)
