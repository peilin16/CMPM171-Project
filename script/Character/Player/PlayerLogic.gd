extends Character_logic
class_name Player_logic

# =========================
# Mahjong Loadout (0..9)
# =========================
@export_range(0, 9) var tiao_count: int = 0  # 条子：攻速
@export_range(0, 9) var tong_count: int = 0  # 筒子：弹幕模式
@export_range(0, 9) var wan_count: int = 0   # 万字：伤害

# 平衡参数（调平衡就改这几行）
@export var base_damage: int = 10                 # 基础子弹伤害（会写入 shoot step 的 "damage"）
@export var tiao_as_per_tile: float = 0.5        # 每张条子 +5% 攻速（9张≈+45%）
@export var fan_base_spread: float = 20.0         # 扇形 spread
@export var random_fan_spread: float = 35.0       # 随机扇形 spread

# 允许手动模式（你之前 1/2/3/4 切模式那套）
# 现在默认是 false：一切以“筒子规则”决定弹幕模式
@export var manual_fire_mode_override: bool = false

enum FireMode { SINGLE, FAN, RANDOM_FAN, MULTI }
var fire_mode: FireMode = FireMode.SINGLE

# FAN 动态 count（由筒子决定）
var _fan_count: int = 2


var current_score:float = 0;


func add_score(score:float = 5)->void:
	current_score += score


func set_fire_mode(m: FireMode) -> void:
	fire_mode = m

func get_fire_mode_name() -> String:
	match get_effective_fire_mode():
		FireMode.SINGLE: return "SINGLE"
		FireMode.FAN: return "FAN"
		FireMode.RANDOM_FAN: return "RANDOM_FAN"
		FireMode.MULTI: return "MULTI"
	return "?"

# =========================
# Mahjong API (可维护入口)
# =========================
func apply_tiles(tiao: int, tong: int, wan: int) -> void:
	tiao_count = clampi(tiao, 0, 9)
	tong_count = clampi(tong, 0, 9)
	wan_count  = clampi(wan, 0, 9)

	# 根据筒子规则更新弹幕参数
	_update_pattern_from_tong()

func get_attack_speed_multiplier() -> float:
	# 条子：每张 +5% 攻速，上限 9 张 => 1.45x
	return 1.0 + float(tiao_count) * tiao_as_per_tile

func get_damage_value() -> int:
	# 万字：每张 +1 伤害，上限 9
	return base_damage + wan_count

func get_effective_fire_mode() -> FireMode:
	if manual_fire_mode_override:
		return fire_mode
	# 否则以筒子决定
	return _mode_from_tong()

# =========================
# Tong rule -> firing mode
# =========================
func _mode_from_tong() -> FireMode:
	# 0..2: SINGLE
	# 3: MULTI
	# 4..8: FAN (count 2..6)
	# 9: RANDOM_FAN
	if tong_count <= 2:
		return FireMode.SINGLE
	if tong_count == 3:
		return FireMode.MULTI
	if tong_count <= 8:
		return FireMode.FAN
	return FireMode.RANDOM_FAN

func _update_pattern_from_tong() -> void:
	# FAN count 规则：4->2,5->3,...,8->6
	if tong_count >= 4 and tong_count <= 8:
		_fan_count = tong_count - 2
	else:
		_fan_count = 2

# =========================
# Shoot Script
# - damage：通过 CastParser -> ShootConfigure.damage 生效
# - 攻速：由 PlayerController 用 get_attack_speed_multiplier() 控制 cooldown
# =========================
func get_shoot_script(target: Vector2) -> Array:
	var dmg := get_damage_value()
	var mode := get_effective_fire_mode()

	match mode:
		FireMode.SINGLE:
			return [{
				"action": "shoot",
				"type": "single",
				"pool": "MAHJONG_BULLET",
				"aim": "TARGET",
				"target": target,
				"speed": 350,
				"color": "RED",
				"damage": dmg
			}]

		FireMode.MULTI:
			# MULTI 的射速不受 controller 的 shoot_cooldown 限制（你要求的）
			# 这里依旧保持你原本的 num/interval
			return [{
				"action": "shoot",
				"type": "multi",
				"num": 5,
				"interval": 0.08,
				"pool": "MAHJONG_BULLET",
				"aim": "TARGET",
				"target": target,
				"speed": 240,
				"color": "RED",
				"damage": dmg
			}]

		FireMode.FAN:
			return [{
				"action": "shoot",
				"type": "fan",
				"spread": fan_base_spread,
				"count": _fan_count,     # ✅ 筒子动态控制
				"time": 1,
				"interval": 0.0,
				"pool": "MAHJONG_BULLET",
				"aim": "TARGET",
				"target": target,
				"speed": 200,
				"color": "BLUE",
				"damage": dmg
			}]

		FireMode.RANDOM_FAN:
			return [{
				"action": "shoot",
				"type": "random_fan",
				"spread": random_fan_spread,
				"count": 6,
				"time": 1,
				"interval": 0.0,
				"overlap": true,
				"fan_seed": -1,      # ✅ 每次随机
				"base_one": false,   # ✅ 更随机
				"pool": "MAHJONG_BULLET",
				"aim": "TARGET",
				"target": target,
				"speed": 220,
				"color": "BLUE",
				"damage": dmg
			}]

	return []
