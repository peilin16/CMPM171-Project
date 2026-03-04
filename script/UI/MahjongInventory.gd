extends Control
class_name MahjongInventory

@onready var tile_container: HBoxContainer = $TileContainer

const PINYIN_NUMS = ["", "yi", "er", "san", "si", "wu", "liu", "qi", "ba", "jiu"]
const SUIT_NAMES = ["wan", "tong", "tiao"]

func _ready() -> void:
	clear_inventory()

# --- 核心接口：更新手牌显示 ---
func update_inventory(hand_array: Array) -> void:
	clear_inventory()
	for tile_data in hand_array:
		_add_tile_to_ui(tile_data)

# 清空当前显示的牌
func clear_inventory() -> void:
	for child in tile_container.get_children():
		child.queue_free()

# 动态生成一张牌并添加到 UI 中
func _add_tile_to_ui(tile_data) -> void:
	var texture_rect = TextureRect.new()
	
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2(45, 65) 
	
	var num_str = PINYIN_NUMS[tile_data.value]
	var suit_str = SUIT_NAMES[tile_data.suit]
	var file_name = num_str + suit_str + ".png"
	var path = "res://assets/mahjung_tiles/three_suites/" + file_name
	
	if ResourceLoader.exists(path):
		texture_rect.texture = load(path)
	else:
		print("Warning: Inventory Tile image not found at -> ", path)
		
	tile_container.add_child(texture_rect)
