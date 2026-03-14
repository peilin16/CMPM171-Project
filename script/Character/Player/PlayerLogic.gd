extends Character_logic
class_name Player_logic

signal mahjong_inventory_changed(hand: Array, tiao: int, tong: int, wan: int)

# =========================
# Mahjong Loadout (0..9)
# =========================
@export_range(0, 9) var tiao_count: int = 0  # 条子：攻速
@export_range(0, 9) var tong_count: int = 0  # 筒子：扩散/扇形倾向
@export_range(0, 9) var wan_count: int = 0   # 万字：伤害

# 平衡参数（调平衡就改这几行）
@export var base_damage: int = 10                 # 基础子弹伤害（会写入 shoot step 的 "damage"）
@export var tiao_as_per_tile: float = 0.05       # 每张条子 +5% 攻速（9张≈+45%）
@export var minimum_shoot_cooldown: float = 0.12
@export var max_attack_speed_multiplier: float = 2.0
@export var fan_base_spread: float = 20.0         # 扇形 spread
@export var random_fan_spread: float = 35.0       # 随机扇形 spread
@export var fan_cooldown_multiplier: float = 1.15
@export var random_fan_cooldown_multiplier: float = 1.3
@export var multi_cooldown_multiplier: float = 1.45
@export var fan_damage_multiplier: float = 0.9
@export var random_fan_damage_multiplier: float = 0.8
@export var multi_damage_multiplier: float = 0.75

# 允许手动模式（你之前 1/2/3/4 切模式那套）
# 现在默认是 false：一切以“麻将手牌”决定弹幕模式
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

# Balance: hand combo bonuses
@export var combo_mixed_hand_damage: float = 0.10
@export var combo_mixed_hand_atk_speed: float = 0.10
@export var combo_mixed_hand_bullet_speed: float = 0.10
@export var combo_mixed_triple_damage: float = 0.25
@export var combo_mixed_triple_atk_speed: float = 0.15
@export var combo_mixed_run_atk_speed: float = 0.20
@export var combo_mixed_run_bullet_speed: float = 0.20
@export var combo_mixed_run_move_speed: float = 0.10
@export var combo_four_winds_move_speed: float = 0.20
@export var combo_four_winds_atk_speed: float = 0.20
@export var combo_four_winds_defense: float = 0.10
@export var combo_three_dragons_damage: float = 0.35
@export var combo_three_dragons_bullet_speed: float = 0.20
@export var combo_three_dragons_score: float = 0.25
@export var combo_four_flowers_atk_speed: float = 0.12
@export var combo_four_flowers_bullet_speed: float = 0.12
@export var combo_four_flowers_move_speed: float = 0.12
@export var combo_four_seasons_damage: float = 0.12
@export var combo_four_seasons_atk_speed: float = 0.12
@export var combo_four_seasons_move_speed: float = 0.12

# Computed bonus multipliers from special tiles
var _bonus_atk_speed: float = 0.0
var _bonus_damage: float = 0.0
var _bonus_move_speed: float = 0.0
var _bonus_bullet_speed: float = 0.0
var _bonus_score: float = 0.0
var _bonus_defense: float = 0.0
var _active_combo_names: Array[String] = []
enum FireMode { SINGLE, FAN, RANDOM_FAN, MULTI }
var fire_mode: FireMode = FireMode.SINGLE

# 动态弹幕参数（由麻将手牌决定）
var _fan_count: int = 2
var _multi_shot_count: int = 5
var _random_fan_count: int = 6
var _burst_repeat_count: int = 1
var _burst_interval: float = 0.08
var hand_tiles: Array = []


var current_score:float = 0;


func add_score(score:float = 5)->void:
	current_score += score * get_score_multiplier()


func set_fire_mode(m: FireMode) -> void:
	fire_mode = m

func get_fire_mode_name() -> String:
	var mode := get_effective_fire_mode()
	var mode_name := _get_fire_mode_base_name(mode)
	if mode == FireMode.MULTI:
		return mode_name
	if _burst_repeat_count > 1:
		return "%s + BURST x%d" % [mode_name, _burst_repeat_count]
	return mode_name

func _get_fire_mode_base_name(mode: FireMode) -> String:
	match mode:
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

	# 根据麻将手牌更新弹幕参数
	_update_pattern_from_hand()
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

func get_active_combo_names() -> Array[String]:
	return _active_combo_names.duplicate()

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
	# 条子：每张 +5% 攻速，上限 9 张，再叠加特殊牌加成，并限制自动射击节奏上限
	var total_multiplier: float = 1.0 + float(tiao_count) * tiao_as_per_tile + _bonus_atk_speed
	return min(total_multiplier, max_attack_speed_multiplier)

func get_fire_cooldown_multiplier() -> float:
	var burst_penalty: float = 1.0 + float(maxi(_burst_repeat_count - 1, 0)) * 0.18
	match get_effective_fire_mode():
		FireMode.FAN:
			return fan_cooldown_multiplier * burst_penalty
		FireMode.RANDOM_FAN:
			return random_fan_cooldown_multiplier * burst_penalty
		FireMode.MULTI:
			return multi_cooldown_multiplier
	return burst_penalty

func get_fire_damage_multiplier() -> float:
	var burst_penalty: float = 1.0 - float(maxi(_burst_repeat_count - 1, 0)) * 0.08
	burst_penalty = max(burst_penalty, 0.72)
	match get_effective_fire_mode():
		FireMode.FAN:
			return fan_damage_multiplier * burst_penalty
		FireMode.RANDOM_FAN:
			return random_fan_damage_multiplier * burst_penalty
		FireMode.MULTI:
			return multi_damage_multiplier
	return burst_penalty

func get_effective_shoot_cooldown(base_cooldown: float) -> float:
	var effective_cooldown: float = base_cooldown * get_fire_cooldown_multiplier() / max(get_attack_speed_multiplier(), 0.01)
	return max(effective_cooldown, minimum_shoot_cooldown)

func get_damage_value() -> int:
	# 万字：每张 +1 伤害，上限 9, then multiply by special damage bonus
	var raw: float = float(base_damage + wan_count)
	var scaled_damage: float = raw * (1.0 + _bonus_damage) * get_fire_damage_multiplier()
	return maxi(1, int(round(scaled_damage)))

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
	# 否则以麻将手牌决定
	return _mode_from_mahjong_hand()

# =========================
# Mahjong hand -> firing mode
# =========================
func _mode_from_mahjong_hand() -> FireMode:
	if _active_combo_names.has("Three Dragons") or _active_combo_names.has("Four Winds"):
		return FireMode.RANDOM_FAN
	if _active_combo_names.has("Three-Suit Run") or _active_combo_names.has("Triple Match"):
		return FireMode.FAN

	if tong_count > max(wan_count, tiao_count):
		return FireMode.FAN
	if tong_count > 0 and _has_multiple_regular_suits():
		return FireMode.FAN

	if _has_all_three_regular_suits():
		return FireMode.RANDOM_FAN
	return FireMode.SINGLE

func _update_pattern_from_hand() -> void:
	var regular_tile_total: int = wan_count + tong_count + tiao_count
	var distinct_regular_values: int = _count_distinct_regular_values()
	var combo_bonus: int = mini(_active_combo_names.size(), 2)

	_fan_count = clampi(2 + int(distinct_regular_values / 4) + combo_bonus, 2, 5)
	_multi_shot_count = clampi(2 + int(tiao_count / 3) + combo_bonus, 2, 5)
	_random_fan_count = clampi(4 + int(regular_tile_total / 5) + combo_bonus, 4, 7)
	_fan_count = _ensure_odd_count(_fan_count)
	_random_fan_count = _ensure_odd_count(_random_fan_count)
	_burst_repeat_count = clampi(1 + int(tiao_count / 4), 1, 3)
	_burst_interval = max(0.045, 0.09 - float(tiao_count) * 0.004)

	if _active_combo_names.has("Three-Suit Run"):
		_fan_count = maxi(_fan_count, 4)
		_fan_count = _ensure_odd_count(_fan_count)
		_burst_repeat_count = maxi(_burst_repeat_count, 2)
		_burst_interval = min(_burst_interval, 0.06)
	if _active_combo_names.has("Three Dragons") or _active_combo_names.has("Four Winds"):
		_random_fan_count = maxi(_random_fan_count, 6)
		_random_fan_count = _ensure_odd_count(_random_fan_count)
		_burst_repeat_count = maxi(_burst_repeat_count, 2)
	if _active_combo_names.has("Mixed Hand") or _active_combo_names.has("Four Flowers"):
		_burst_repeat_count = maxi(_burst_repeat_count, 2)

func _ensure_odd_count(count: int) -> int:
	var clamped_count := maxi(1, count)
	if clamped_count % 2 == 0:
		clamped_count += 1
	return clamped_count

func _recalculate_special_buffs() -> void:
	_bonus_atk_speed = 0.0
	_bonus_damage = 0.0
	_bonus_move_speed = 0.0
	_bonus_bullet_speed = 0.0
	_bonus_score = 0.0
	_bonus_defense = 0.0
	_active_combo_names.clear()

	var regular_tiles_by_suit := [{}, {}, {}]
	var wind_values := {}
	var dragon_values := {}
	var flower_values := {}
	var season_values := {}

	for tile_data in hand_tiles:
		var suit := int(tile_data.get("suit", -1))
		var value := int(tile_data.get("value", -1))

		if suit >= 0 and suit <= 2 and value >= 1 and value <= 9:
			regular_tiles_by_suit[suit][value] = int(regular_tiles_by_suit[suit].get(value, 0)) + 1

		if suit == SUIT_WIND:
			wind_values[value] = true
			match value:
				0: _bonus_move_speed += wind_move_spd       # East
				1: _bonus_damage += wind_dmg                # South
				2: _bonus_defense += wind_defense            # West
				3: _bonus_atk_speed += wind_atk_spd          # North
		elif suit == SUIT_DRAGON:
			dragon_values[value] = true
			match value:
				0: _bonus_damage += dragon_dmg               # Red
				1: _bonus_score += dragon_score               # Green
				2: _bonus_bullet_speed += dragon_bullet_spd   # White
		elif suit == SUIT_FLOWER:
			flower_values[value] = true
			match value:
				0: _bonus_atk_speed += flower_atk_spd        # Plum
				1: _bonus_move_speed += flower_move_spd      # Orchid
				2: _bonus_bullet_speed += flower_bullet_spd  # Bamboo
				3: _bonus_damage += flower_dmg               # Chrysanthemum
		elif suit == SUIT_SEASON:
			season_values[value] = true
			match value:
				0: _bonus_atk_speed += season_atk_spd        # Spring
				1: _bonus_damage += season_dmg               # Summer
				2: _bonus_bullet_speed += season_bullet_spd  # Fall
				3: _bonus_move_speed += season_move_spd      # Winter

	_apply_hand_combo_bonuses(regular_tiles_by_suit, wind_values, dragon_values, flower_values, season_values)

func _apply_hand_combo_bonuses(
		regular_tiles_by_suit: Array,
		wind_values: Dictionary,
		dragon_values: Dictionary,
		flower_values: Dictionary,
		season_values: Dictionary) -> void:
	if wan_count > 0 and tong_count > 0 and tiao_count > 0:
		_bonus_damage += combo_mixed_hand_damage
		_bonus_atk_speed += combo_mixed_hand_atk_speed
		_bonus_bullet_speed += combo_mixed_hand_bullet_speed
		_register_combo("Mixed Hand")

	for value in range(1, 10):
		if _has_tile_value_in_all_suits(regular_tiles_by_suit, value):
			_bonus_damage += combo_mixed_triple_damage
			_bonus_atk_speed += combo_mixed_triple_atk_speed
			_register_combo("Triple Match")
			break

	for start_value in range(1, 8):
		if _has_sequence_in_all_suits(regular_tiles_by_suit, start_value):
			_bonus_atk_speed += combo_mixed_run_atk_speed
			_bonus_bullet_speed += combo_mixed_run_bullet_speed
			_bonus_move_speed += combo_mixed_run_move_speed
			_register_combo("Three-Suit Run")
			break

	if wind_values.size() == 4:
		_bonus_move_speed += combo_four_winds_move_speed
		_bonus_atk_speed += combo_four_winds_atk_speed
		_bonus_defense += combo_four_winds_defense
		_register_combo("Four Winds")

	if dragon_values.size() == 3:
		_bonus_damage += combo_three_dragons_damage
		_bonus_bullet_speed += combo_three_dragons_bullet_speed
		_bonus_score += combo_three_dragons_score
		_register_combo("Three Dragons")

	if flower_values.size() == 4:
		_bonus_atk_speed += combo_four_flowers_atk_speed
		_bonus_bullet_speed += combo_four_flowers_bullet_speed
		_bonus_move_speed += combo_four_flowers_move_speed
		_register_combo("Four Flowers")

	if season_values.size() == 4:
		_bonus_damage += combo_four_seasons_damage
		_bonus_atk_speed += combo_four_seasons_atk_speed
		_bonus_move_speed += combo_four_seasons_move_speed
		_register_combo("Four Seasons")

func _has_tile_value_in_all_suits(regular_tiles_by_suit: Array, value: int) -> bool:
	for suit_tiles in regular_tiles_by_suit:
		if int(suit_tiles.get(value, 0)) <= 0:
			return false
	return true

func _has_sequence_in_all_suits(regular_tiles_by_suit: Array, start_value: int) -> bool:
	for suit_tiles in regular_tiles_by_suit:
		for offset in range(3):
			if int(suit_tiles.get(start_value + offset, 0)) <= 0:
				return false
	return true

func _register_combo(combo_name: String) -> void:
	if not _active_combo_names.has(combo_name):
		_active_combo_names.append(combo_name)

func _get_dominant_regular_suit() -> int:
	var counts := [wan_count, tong_count, tiao_count]
	var best_suit: int = -1
	var best_count: int = 0
	var is_tie: bool = false

	for suit_index in range(counts.size()):
		var count: int = counts[suit_index]
		if count > best_count:
			best_count = count
			best_suit = suit_index
			is_tie = false
		elif count > 0 and count == best_count:
			is_tie = true

	if best_count <= 0 or is_tie:
		return -1
	return best_suit

func _has_multiple_regular_suits() -> bool:
	var suit_total: int = 0
	if wan_count > 0:
		suit_total += 1
	if tong_count > 0:
		suit_total += 1
	if tiao_count > 0:
		suit_total += 1
	return suit_total >= 2

func _has_all_three_regular_suits() -> bool:
	return wan_count > 0 and tong_count > 0 and tiao_count > 0

func _count_distinct_regular_values() -> int:
	var values := {}
	for tile_data in hand_tiles:
		var suit := int(tile_data.get("suit", -1))
		var value := int(tile_data.get("value", -1))
		if suit >= 0 and suit <= 2 and value >= 1 and value <= 9:
			values[value] = true
	return values.size()

# =========================
# Shoot Script
# - damage：通过 CastParser -> ShootConfigure.damage 生效
# - 攻速：由 PlayerController 用 get_attack_speed_multiplier() 控制 cooldown
# =========================
func get_shoot_script(target: Vector2) -> Array:
	var dmg := get_damage_value()
	var mode := get_effective_fire_mode()
	var bspd := get_bullet_speed_multiplier()
	var burst_repeat := _burst_repeat_count
	var burst_interval := _burst_interval

	match mode:
		FireMode.SINGLE:
			if burst_repeat > 1:
				return [{
					"action": "shoot",
					"type": "multi",
					"num": burst_repeat,
					"interval": burst_interval,
					"pool": "MAHJONG_BULLET",
					"aim": "TARGET",
					"target": target,
					"speed": int(350 * bspd),
					"color": "RED",
					"damage": dmg
				}]
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
			return [{
				"action": "shoot",
				"type": "multi",
				"num": _multi_shot_count,
				"interval": burst_interval,
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
				"count": _fan_count,
				"time": burst_repeat,
				"interval": burst_interval,
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
				"count": _random_fan_count,
				"time": burst_repeat,
				"interval": burst_interval,
				"overlap": true,
				"fan_seed": -1,      # ✅ 每次随机
				"base_one": true,
				"pool": "MAHJONG_BULLET",
				"aim": "TARGET",
				"target": target,
				"speed": int(220 * bspd),
				"color": "BLUE",
				"damage": dmg
			}]

	return []
