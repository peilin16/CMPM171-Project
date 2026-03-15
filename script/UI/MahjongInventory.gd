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
	
	if hand_array.is_empty():
		return
		
	# 1. 自动理牌 (先克隆一份数组，避免影响底层的真实手牌顺序)
	var sorted_hand = hand_array.duplicate()
	sorted_hand.sort_custom(_sort_tiles)
	
	# 2. 动态计算缩放尺寸 (防溢出)
	var tile_count = sorted_hand.size()
	var max_w = 20.0
	var max_h = 40.0
	var separation = 5.0 # 假设 HBoxContainer 间距为 5，可根据你的真实 Theme 调整
	
	# 获取当前界面的可用宽度 (留 20px 安全边距)
	# 如果 UI 尚未完全渲染导致 size.x 为 0，则回退使用屏幕宽度
	var available_width = size.x - 20.0
	if available_width <= 0:
		available_width = get_viewport_rect().size.x - 20.0
		
	var target_w = max_w
	var target_h = max_h
	
	var required_width = (max_w * tile_count) + (separation * (tile_count - 1))
	
	# 如果所需宽度超过了屏幕可用宽度，进行等比例缩小
	if required_width > available_width:
		# 计算压缩后的宽度 (保证最小不低于 5px)
		target_w = max((available_width - (separation * (tile_count - 1))) / tile_count, 5.0)
		# 维持 1:2 的长宽比例
		target_h = target_w * 2.0 
		
	var target_size = Vector2(target_w, target_h)
	
	# 3. 按理好的顺序和计算好的尺寸生成 UI
	for tile_data in sorted_hand:
		_add_tile_to_ui(tile_data, target_size)

# --- 辅助排序函数 ---
# 规则：先比较花色 (suit)，花色相同的再比较点数 (value)
func _sort_tiles(a: Dictionary, b: Dictionary) -> bool:
	var suit_a = int(a.get("suit", -1))
	var suit_b = int(b.get("suit", -1))
	if suit_a != suit_b:
		return suit_a < suit_b
		
	var val_a = int(a.get("value", 0))
	var val_b = int(b.get("value", 0))
	return val_a < val_b

# 清空当前显示的牌
func clear_inventory() -> void:
	for child in tile_container.get_children():
		child.queue_free()

# 动态生成一张牌并添加到 UI 中
func _add_tile_to_ui(tile_data: Dictionary, target_size: Vector2) -> void:
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
