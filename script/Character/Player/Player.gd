extends Character
#Player.gd
class_name Player



# --- 麻将系统变量 -# -----------------------------------------------------------------------------------------
var collected_mahjongs: Array[Mahjong] = []
# ------------------------------------------------------------------------------------------------------------




#speed
@export  var player_velocity :float= 320.0;
#@export var rumia_slow_velocity:float = 80;
#@export  var rumia_accleration :float= 400.0;

@export  var defence :bool= false

@export var coldDown: int = 4;
@export var isColdDown:bool= false;

@export var respawn_delay_sec: float = 2.0
@export var invincible_sec: float = 3.0          
@export var initial_shield_sec: float = 5.0        
@export var respawn_move_speed: float = 650.0

@export var power:float = 0;
@export var score:float = 0;





# ------------------------------------------------------------------------------------------------------------
# --- 初始化 (包含作弊代码) ---
func _init() -> void:
	isEnemy = false;
	
	# [修改点] 为了确保 .new() 创建时生效，作弊代码必须放在 _init 里
	# --------------------------------------------------------- Range后面的数字就是作弊的条子获得数量
	print(">>> Player 初始化：开启调试模式，自动装备5张条子 <<<")
	for i in range(10):
		var cheat_tile = Mahjong.new() 
		cheat_tile.suit = Mahjong.Suit.BAMBOO # 条子
		cheat_tile.rank = 1 # 一索
		pick_up_mahjong(cheat_tile) 
	# ---------------------------------------------------------










# --- 麻将功能函数 ---

# 功能1: 拾取麻将
func pick_up_mahjong(tile: Mahjong) -> void:
	if tile:
		collected_mahjongs.append(tile)
		# 打印日志
		print("Player 获得: ", tile.suit, "(", tile.rank, ") | 当前总数: ", collected_mahjongs.size())

# 功能2: 获取攻击速度倍率 (基于条子数量)
func get_attack_speed_multiplier() -> float:
	var multiplier: float = 1.0
	
	for tile in collected_mahjongs:
		if tile.suit == Mahjong.Suit.BAMBOO:
			multiplier += 0.1 # 每张条子 +10% 攻速
			
	return multiplier

# 功能3: 获取额外弹道数量 (基于条子数量)
func get_extra_projectile_count() -> int:
	var bamboo_count: int = 0
	
	for tile in collected_mahjongs:
		if tile.suit == Mahjong.Suit.BAMBOO:
			bamboo_count += 1
			
	# 每3张条子 +1 个弹道
	return floor(bamboo_count / 3)
# ------------------------------------------------------------------------------------------------------------