# ShootRunner.gd
extends Runner
class_name Shoot_runner

@export var default_pattern: Shooting_pattern   # default pattern

var _current_pattern: Shooting_pattern = null
var _current_configure: Shoot_configure = null
var container :Node2D;


# ------------------------------------------------------------------------------------------------------------
# 缓存玩家引用
var _cached_player: Player = null
# ------------------------------------------------------------------------------------------------------------

func _ready() -> void:
	super._ready();
	container = get_tree().current_scene.get_node("BulletContainer");
	
	# 尝试方法1: 通过组查找 (仅当 Player 节点在场景树中时有效)
	var player_node = get_tree().get_first_node_in_group("Player")
	if player_node is Player:
		_cached_player = player_node

func start(actor, pattern: Pattern, configure: Configure) -> void:
	controller = configure.controller;
	
	# --- [修复核心] 强力获取玩家数据逻辑 ---
	if _cached_player == null and controller:
		# 尝试获取 controller 里的 _character 变量 (即使它是私有的)
		var potential_player = controller.get("_character")
		if potential_player is Player:
			_cached_player = potential_player
			# 打印一次确认连接成功 (调试用)
			print_debug_connection()
		# 备用：如果有公开的 character 属性
		elif "character" in controller and controller.character is Player:
			_cached_player = controller.character
			print_debug_connection()
	# -------------------------------------
	
	stop()
	if pattern == null or configure == null:
		return
		
	_current_pattern = pattern as Shooting_pattern
	_current_configure = configure as Shoot_configure
	is_running = true;
	_current_pattern._ready(self, _current_configure);
	is_finished = false

# 辅助调试函数
func print_debug_connection():
	if _cached_player:
		var buff = _cached_player.get_attack_speed_multiplier()
		# 只打印一次，避免刷屏。如果看到倍率 > 1.0，说明成功了！
		print("ShootRunner 已连接到 Player 数据! 当前攻速倍率: ", buff)

func _physics_process(delta: float) -> void:
	if not is_running  or is_finished:		return
	
	# --- 应用攻速 Buff ---
	var final_delta = delta
	if _cached_player:
		# 让弹幕模式的时间流逝变快，从而匹配高频射击
		final_delta *= _cached_player.get_attack_speed_multiplier()
	# -------------------

	is_finished = _current_pattern.play(self, _current_configure, final_delta);
	
	if is_finished:
		end();

func end()->void:
	if _current_pattern:
		_current_pattern.deactive();
	is_finished = true

func stop() -> void:
	if not is_running:
		return
	is_running = false