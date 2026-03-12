extends Character_logic
class_name Player_logic

signal mahjong_inventory_changed(hand: Array, tiao: int, tong: int, wan: int)

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
# =========================
# Special Tile Categories
# =========================
const SUIT_DORA = 3
const SUIT_WIND = 4
const SUIT_DRAGON = 5
const SUIT_FLOWER = 6
const SUIT_SEASON = 7

# Balance: Wind bonuses
@export var wind_move_spd: float = 0.15        # East: +15% move speed
@export var wind_dmg: float = 0.12             # South: +12% damage
@export var wind_defense: float = 0.15         # West: 15% damage reduction
@export var wind_atk_spd: float = 0.15         # North: +15% attack speed
# Balance: Dragon bonuses
@export var dragon_dmg: float = 0.25           # Red: +25% damage
@export var dragon_score: float = 0.25         # Green: +25% score gain
@export var dragon_bullet_spd: float = 0.15    # White: +15% bullet speed
# Balance: Flower bonuses
@export var flower_atk_spd: float = 0.08       # Plum: +8% attack speed
@export var flower_move_spd: float = 0.08      # Orchid: +8% move speed
@export var flower_bullet_spd: float = 0.10    # Bamboo: +10% bullet speed
@export var flower_dmg: float = 0.08           # Chrysanthemum: +8% damage
# Balance: Season bonuses
@export var season_atk_spd: float = 0.10       # Spring: +10% attack speed
@export var season_dmg: float = 0.10           # Summer: +10% damage
@export var season_bullet_spd: float = 0.08    # Fall: +8% bullet speed
@export var season_move_spd: float = 0.10      # Winter: +10% move speed

# Computed bonus multipliers from special tiles
var _bonus_atk_speed: float = 0.0
var _bonus_damage: float = 0.0
var _bonus_move_speed: float = 0.0
var _bonus_bullet_speed: float = 0.0
var _bonus_score: float = 0.0
var _bonus_defense: float = 0.0
enum FireMode { SINGLE, FAN, RANDOM_FAN, MULTI }
var fire_mode: FireMode = FireMode.SINGLE

# FAN 动态 count（由筒子决定）
var _fan_count: int = 2
var hand_tiles: Array = []


var current_score:float = 0;


func add_score(score:float = 5)->void:
	current_score += score * get_score_multiplier()


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
func apply_tiles(tiao: int, tong: int, wan: int, sync_hand: bool = false) -> void:
	tiao_count = clampi(tiao, 0, 9)
	tong_count = clampi(tong, 0, 9)
	wan_count  = clampi(wan, 0, 9)

	if sync_hand:
		hand_tiles = _build_hand_from_counts(tiao_count, tong_count, wan_count)

	# 根据筒子规则更新弹幕参数
	_update_pattern_from_tong()
	_emit_mahjong_inventory_changed()

func add_tile(suit: int, value: int) -> void:
	# Regular suits 0-2 (value 1-9)
	if suit >= 0 and suit <= 2:
		if value < 1 or value > 9:
			return
	# Dora suit 3 (value 0=wan, 1=tong, 2=tiao)
	elif suit == SUIT_DORA:
		if value < 0 or value > 2:
			return
	# Wind suit 4 (value 0-3)
	elif suit == SUIT_WIND:
		if value < 0 or value > 3:
			return
	# Dragon suit 5 (value 0-2)
	elif suit == SUIT_DRAGON:
		if value < 0 or value > 2:
			return
	# Flower suit 6 (value 0-3)
	elif suit == SUIT_FLOWER:
		if value < 0 or value > 3:
			return
	# Season suit 7 (value 0-3)
	elif suit == SUIT_SEASON:
		if value < 0 or value > 3:
			return
	else:
		return

	hand_tiles.append({"suit": suit, "value": value})
	_recalculate_counts_from_hand()

func clear_tiles() -> void:
	hand_tiles.clear()
	apply_tiles(0, 0, 0)

func get_hand_tiles() -> Array:
	return hand_tiles.duplicate(true)

func _recalculate_counts_from_hand() -> void:
	var suit_counts := [0, 0, 0]
	for tile_data in hand_tiles:
		var suit := int(tile_data.get("suit", -1))
		if suit >= 0 and suit <= 2:
			suit_counts[suit] += 1
		elif suit == SUIT_DORA:
			# Dora counts as 2 of its base suit
			var base_suit := int(tile_data.get("value", -1))
			if base_suit >= 0 and base_suit <= 2:
				suit_counts[base_suit] += 2

	_recalculate_special_buffs()
	apply_tiles(suit_counts[2], suit_counts[1], suit_counts[0])

func _build_hand_from_counts(tiao: int, tong: int, wan: int) -> Array:
	var built_hand: Array = []
	for index in range(wan):
		built_hand.append({"suit": 0, "value": (index % 9) + 1})
	for index in range(tong):
		built_hand.append({"suit": 1, "value": (index % 9) + 1})
	for index in range(tiao):
		built_hand.append({"suit": 2, "value": (index % 9) + 1})
	return built_hand

func _emit_mahjong_inventory_changed() -> void:
	mahjong_inventory_changed.emit(get_hand_tiles(), tiao_count, tong_count, wan_count)

func get_attack_speed_multiplier() -> float:
	# 条子：每张 +5% 攻速，上限 9 张 => 1.45x + special bonuses
	return 1.0 + float(tiao_count) * tiao_as_per_tile + _bonus_atk_speed

func get_damage_value() -> int:
	# 万字：每张 +1 伤害，上限 9, then multiply by special damage bonus
	var raw := float(base_damage + wan_count)
	return int(raw * (1.0 + _bonus_damage))

func get_move_speed_multiplier() -> float:
	return 1.0 + _bonus_move_speed

func get_bullet_speed_multiplier() -> float:
	return 1.0 + _bonus_bullet_speed

func get_score_multiplier() -> float:
	return 1.0 + _bonus_score

func get_damage_reduction() -> float:
	return clampf(_bonus_defense, 0.0, 0.75)

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

func _recalculate_special_buffs() -> void:
	_bonus_atk_speed = 0.0
	_bonus_damage = 0.0
	_bonus_move_speed = 0.0
	_bonus_bullet_speed = 0.0
	_bonus_score = 0.0
	_bonus_defense = 0.0

	for tile_data in hand_tiles:
		var suit := int(tile_data.get("suit", -1))
		var value := int(tile_data.get("value", -1))

		if suit == SUIT_WIND:
			match value:
				0: _bonus_move_speed += wind_move_spd       # East
				1: _bonus_damage += wind_dmg                # South
				2: _bonus_defense += wind_defense            # West
				3: _bonus_atk_speed += wind_atk_spd          # North
		elif suit == SUIT_DRAGON:
			match value:
				0: _bonus_damage += dragon_dmg               # Red
				1: _bonus_score += dragon_score               # Green
				2: _bonus_bullet_speed += dragon_bullet_spd   # White
		elif suit == SUIT_FLOWER:
			match value:
				0: _bonus_atk_speed += flower_atk_spd        # Plum
				1: _bonus_move_speed += flower_move_spd      # Orchid
				2: _bonus_bullet_speed += flower_bullet_spd  # Bamboo
				3: _bonus_damage += flower_dmg               # Chrysanthemum
		elif suit == SUIT_SEASON:
			match value:
				0: _bonus_atk_speed += season_atk_spd        # Spring
				1: _bonus_damage += season_dmg               # Summer
				2: _bonus_bullet_speed += season_bullet_spd  # Fall
				3: _bonus_move_speed += season_move_spd      # Winter

# =========================
# Shoot Script
# - damage：通过 CastParser -> ShootConfigure.damage 生效
# - 攻速：由 PlayerController 用 get_attack_speed_multiplier() 控制 cooldown
# =========================
func get_shoot_script(target: Vector2) -> Array:
	var dmg := get_damage_value()
	var mode := get_effective_fire_mode()
	var bspd := get_bullet_speed_multiplier()

	match mode:
		FireMode.SINGLE:
			return [{
				"action": "shoot",
				"type": "single",
				"pool": "MAHJONG_BULLET",
				"aim": "TARGET",
				"target": target,
				"speed": int(350 * bspd),
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
				"speed": int(240 * bspd),
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
				"speed": int(200 * bspd),
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
				"speed": int(220 * bspd),
				"color": "BLUE",
				"damage": dmg
			}]

	return []
