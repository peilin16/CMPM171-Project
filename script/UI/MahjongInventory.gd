extends Control
class_name MahjongInventory

@onready var tile_container: HBoxContainer = $TileContainer

const PINYIN_NUMS = ["", "yi", "er", "san", "si", "wu", "liu", "qi", "ba", "jiu"]
const SUIT_NAMES = ["wan", "tong", "tiao"]

# Image paths for special tile categories
const SPECIAL_TILE_IMAGES = {
	# Dora (suit 3)
	"3_0": "res://assets/mahjung_tiles/dora_bonus/wuwanRed.png",
	"3_1": "res://assets/mahjung_tiles/dora_bonus/wutongRed.png",
	"3_2": "res://assets/mahjung_tiles/dora_bonus/wutiaoRed.png",
	# Winds (suit 4)
	"4_0": "res://assets/mahjung_tiles/winds_&_dragons/East.png",
	"4_1": "res://assets/mahjung_tiles/winds_&_dragons/South.png",
	"4_2": "res://assets/mahjung_tiles/winds_&_dragons/West.png",
	"4_3": "res://assets/mahjung_tiles/winds_&_dragons/North.png",
	# Dragons (suit 5)
	"5_0": "res://assets/mahjung_tiles/winds_&_dragons/Red.png",
	"5_1": "res://assets/mahjung_tiles/winds_&_dragons/Green.png",
	"5_2": "res://assets/mahjung_tiles/winds_&_dragons/White.png",
	# Flowers (suit 6)
	"6_0": "res://assets/mahjung_tiles/flowers_&_seasons/plum.png",
	"6_1": "res://assets/mahjung_tiles/flowers_&_seasons/orchid.png",
	"6_2": "res://assets/mahjung_tiles/flowers_&_seasons/bamboo.png",
	"6_3": "res://assets/mahjung_tiles/flowers_&_seasons/chrysanthemum.png",
	# Seasons (suit 7)
	"7_0": "res://assets/mahjung_tiles/flowers_&_seasons/spring.png",
	"7_1": "res://assets/mahjung_tiles/flowers_&_seasons/summer.png",
	"7_2": "res://assets/mahjung_tiles/flowers_&_seasons/fall.png",
	"7_3": "res://assets/mahjung_tiles/flowers_&_seasons/winter.png",
}

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
	
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	texture_rect.custom_minimum_size = Vector2(45, 65)
	texture_rect.set_size(Vector2(25, 35))  
	texture_rect.clip_contents = true       
	
	var value := int(tile_data.get("value", 0))
	var suit := int(tile_data.get("suit", -1))
	
	var path := ""
	if suit >= 0 and suit <= 2:
		if value < 1 or value >= PINYIN_NUMS.size():
			return
		var num_str = PINYIN_NUMS[value]
		var suit_str = SUIT_NAMES[suit]
		path = "res://assets/mahjung_tiles/three_suites/" + num_str + suit_str + ".png"
	else:
		var key = str(suit) + "_" + str(value)
		path = SPECIAL_TILE_IMAGES.get(key, "")
	
	if path != "" and ResourceLoader.exists(path):
		texture_rect.texture = load(path)
	else:
		print("Warning: Inventory Tile image not found at -> ", path)
		
	tile_container.add_child(texture_rect)
