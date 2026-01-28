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

# 声明 Move_data 变量
var move_data: Move_data = Move_data.new()

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
	handle_dash_cooldown(delta)

# --- 核心移动逻辑 ---
# 注意：这里改回了 'delta' (去掉了下划线)，因为下面要用到它
func move(delta: float, speed: float = _character.player_velocity) -> void:
	# 1. 获取输入
	input_vector = Input.get_vector("left", "right", "up", "down")
	
	# 2. 冲刺判定
	if Input.is_action_just_pressed("avoid") and can_dash and input_vector != Vector2.ZERO:
		start_dash()

	# 3. 计算速度
	var current_speed = speed
	if is_dashing:
		current_speed *= dash_speed_multiplier
	
	velocity = input_vector * current_speed
	
	# 4. 执行移动
	move_and_slide()
	
	# 5. 屏幕限制
	global_position = global_position.clamp(Vector2.ZERO, screen_size)
	
	# 6. 动画翻转
	if input_vector.x != 0:
		animated_sprite.flip_h = input_vector.x < 0
	
	# 7. 记录移动数据
	move_data.record_motion(global_position, delta)

# --- 冲刺/闪避系统 ---
func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	# vfx_parser.spawn_vfx("dash_effect", global_position) 

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
	var shoot_script: Array = logic.get_shoot_script(payload["world_pos"])
	shoot(shoot_script)

func shoot(bullet_script: Array) -> void:
	scheduler.preemption(bullet_script)
