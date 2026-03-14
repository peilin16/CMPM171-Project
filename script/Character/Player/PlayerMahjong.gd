extends Node
class_name Player_mahjong

@export var cheat_enabled: bool = true
@export_range(0, 9) var cheat_tiao: int = 0
@export_range(0, 9) var cheat_tong: int = 0
@export_range(0, 9) var cheat_wan: int = 0

var _player: Player_controller
var _logic: Player_logic
var _inventory_ui: MahjongInventory
var _last_cheat_tiao: int = -1
var _last_cheat_tong: int = -1
var _last_cheat_wan: int = -1

# Special tile names for logging
const SPECIAL_TILE_NAMES = {
	"3_0": "Dora Wan", "3_1": "Dora Tong", "3_2": "Dora Tiao",
	"4_0": "East Wind", "4_1": "South Wind", "4_2": "West Wind", "4_3": "North Wind",
	"5_0": "Red Dragon", "5_1": "Green Dragon", "5_2": "White Dragon",
	"6_0": "Plum", "6_1": "Orchid", "6_2": "Bamboo", "6_3": "Chrysanthemum",
	"7_0": "Spring", "7_1": "Summer", "7_2": "Fall", "7_3": "Winter",
}

func _ready() -> void:
	_player = get_parent() as Player_controller
	if _player == null:
		return

	_logic = _player.logic
	_inventory_ui = _player.get_node_or_null("MahjongInventory") as MahjongInventory

	if _logic and not _logic.mahjong_inventory_changed.is_connected(_on_mahjong_inventory_changed):
		_logic.mahjong_inventory_changed.connect(_on_mahjong_inventory_changed)

	var player_manager: PlayerManager = GameManager.player_manager
	if player_manager and player_manager.has_saved_mahjong_hand():
		_sync_cheat_cache()
		_restore_saved_hand(player_manager.get_saved_mahjong_hand())
	else:
		_apply_cheat_if_needed(true)
		if not cheat_enabled and _logic:
			_on_mahjong_inventory_changed(_logic.get_hand_tiles(), _logic.tiao_count, _logic.tong_count, _logic.wan_count)

func _physics_process(_delta: float) -> void:
	_apply_cheat_if_needed(false)

func add_tile(suit: int, value: int) -> void:
	if _logic == null:
		return
	_logic.add_tile(suit, value)
	var tile_name: String
	if suit >= 0 and suit <= 2:
		tile_name = MahjongInventory.PINYIN_NUMS[value] + MahjongInventory.SUIT_NAMES[suit]
	else:
		tile_name = SPECIAL_TILE_NAMES.get(str(suit) + "_" + str(value), "Unknown")
	print("[Mahjong] picked ", tile_name)

func get_hand_tiles() -> Array:
	if _logic == null:
		return []
	return _logic.get_hand_tiles()

func _on_mahjong_inventory_changed(hand: Array, tiao: int, tong: int, wan: int) -> void:
	if is_instance_valid(_inventory_ui):
		_inventory_ui.update_inventory(hand)

	if GameManager.player_manager:
		GameManager.player_manager.save_mahjong_hand(hand)

	if _player and _logic:
		_player.shoot_cooldown = _logic.get_effective_shoot_cooldown(_player.base_shoot_cooldown)

		print("[Mahjong] tiao=", tiao, " tong=", tong, " wan=", wan,
			" | combos=", _logic.get_active_combo_names(),
			" | mode=", _logic.get_fire_mode_name(),
			" | atk_spd=", _logic.get_attack_speed_multiplier(),
			" | dmg=", _logic.get_damage_value(),
			" | cooldown=", _player.shoot_cooldown,
			" | move_spd=", _logic.get_move_speed_multiplier(),
			" | bullet_spd=", _logic.get_bullet_speed_multiplier(),
			" | defense=", _logic.get_damage_reduction())

func _apply_cheat_if_needed(force: bool) -> void:
	if not cheat_enabled or _logic == null:
		return

	if force \
	or cheat_tiao != _last_cheat_tiao \
	or cheat_tong != _last_cheat_tong \
	or cheat_wan != _last_cheat_wan:

		_last_cheat_tiao = cheat_tiao
		_last_cheat_tong = cheat_tong
		_last_cheat_wan = cheat_wan

		_logic.apply_tiles(cheat_tiao, cheat_tong, cheat_wan, true)

func _restore_saved_hand(saved_hand: Array) -> void:
	if _logic == null:
		return
	_logic.clear_tiles()
	for tile_data in saved_hand:
		var suit: int = int(tile_data.get("suit", -1))
		var value: int = int(tile_data.get("value", 0))
		_logic.add_tile(suit, value)

func _sync_cheat_cache() -> void:
	_last_cheat_tiao = cheat_tiao
	_last_cheat_tong = cheat_tong
	_last_cheat_wan = cheat_wan
