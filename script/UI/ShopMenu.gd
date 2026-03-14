extends Control
class_name Shop_menu
signal tile_chosen(suit: int, value: int)

@onready var option_1: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/TileContainer/Option1
@onready var option_2: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/TileContainer/Option2
@onready var option_3: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/TileContainer/Option3
@onready var skip_button: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/SkipButton
@onready var title_label: Label = $CenterContainer/Panel/MainHBox/VBoxContainer/Title

var current_options: Array = []

# --- 核心：拼音映射表 ---
# 用于将数字 1-9 和花色 0-2 转换为美术文件的名字
const PINYIN_NUMS = ["", "yi", "er", "san", "si", "wu", "liu", "qi", "ba", "jiu"]
const SUIT_NAMES = ["wan", "tong", "tiao"]

# Probability that each shop slot offers a special tile
const SPECIAL_TILE_CHANCE = 0.25

# Special tile definitions: [suit, value, display_name, image_path, tooltip]
# 这里保留原结构，tooltip 字段不再直接用于显示，改为走语言系统
const SPECIAL_TILES = [
	# Dora (suit 3): counts as 2 of its base suit
	[3, 0, "Dora Wan", "res://assets/mahjung_tiles/dora_bonus/wuwanRed.png", "Counts as 2 Wan tiles (+damage)"],
	[3, 1, "Dora Tong", "res://assets/mahjung_tiles/dora_bonus/wutongRed.png", "Counts as 2 Tong tiles (stronger spread / fan patterns)"],
	[3, 2, "Dora Tiao", "res://assets/mahjung_tiles/dora_bonus/wutiaoRed.png", "Counts as 2 Tiao tiles (+atk speed)"],
	# Winds (suit 4)
	[4, 0, "East Wind", "res://assets/mahjung_tiles/winds_&_dragons/East.png", "+15% move speed. Collect all 4 Winds for a major mobility/defense combo."],
	[4, 1, "South Wind", "res://assets/mahjung_tiles/winds_&_dragons/South.png", "+12% damage. Collect all 4 Winds for a major mobility/defense combo."],
	[4, 2, "West Wind", "res://assets/mahjung_tiles/winds_&_dragons/West.png", "15% damage reduction. Collect all 4 Winds for a major mobility/defense combo."],
	[4, 3, "North Wind", "res://assets/mahjung_tiles/winds_&_dragons/North.png", "+15% attack speed. Collect all 4 Winds for a major mobility/defense combo."],
	# Dragons (suit 5)
	[5, 0, "Red Dragon", "res://assets/mahjung_tiles/winds_&_dragons/Red.png", "+25% damage. Collect all 3 Dragons for a major offensive combo."],
	[5, 1, "Green Dragon", "res://assets/mahjung_tiles/winds_&_dragons/Green.png", "+25% score gain. Collect all 3 Dragons for a major offensive combo."],
	[5, 2, "White Dragon", "res://assets/mahjung_tiles/winds_&_dragons/White.png", "+15% bullet speed. Collect all 3 Dragons for a major offensive combo."],
	# Flowers (suit 6)
	[6, 0, "Plum", "res://assets/mahjung_tiles/flowers_&_seasons/plum.png", "+8% attack speed. Collect all 4 Flowers for a utility combo."],
	[6, 1, "Orchid", "res://assets/mahjung_tiles/flowers_&_seasons/orchid.png", "+8% move speed. Collect all 4 Flowers for a utility combo."],
	[6, 2, "Bamboo", "res://assets/mahjung_tiles/flowers_&_seasons/bamboo.png", "+10% bullet speed. Collect all 4 Flowers for a utility combo."],
	[6, 3, "Chrysanthemum", "res://assets/mahjung_tiles/flowers_&_seasons/chrysanthemum.png", "+8% damage. Collect all 4 Flowers for a utility combo."],
	# Seasons (suit 7)
	[7, 0, "Spring", "res://assets/mahjung_tiles/flowers_&_seasons/spring.png", "+10% attack speed. Collect all 4 Seasons for a tempo combo."],
	[7, 1, "Summer", "res://assets/mahjung_tiles/flowers_&_seasons/summer.png", "+10% damage. Collect all 4 Seasons for a tempo combo."],
	[7, 2, "Fall", "res://assets/mahjung_tiles/flowers_&_seasons/fall.png", "+8% bullet speed. Collect all 4 Seasons for a tempo combo."],
	[7, 3, "Winter", "res://assets/mahjung_tiles/flowers_&_seasons/winter.png", "+10% move speed. Collect all 4 Seasons for a tempo combo."],
]

const SUIT_TOOLTIP_KEYS = [
	"shop_tooltip_wan",
	"shop_tooltip_tong",
	"shop_tooltip_tiao"
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 关键步骤：允许按钮上的图标自由拉伸，以适应我们设置的 100x150 尺寸
	for btn in [option_1, option_2, option_3]:
		btn.expand_icon = true
		# 为了保证麻将牌不变形，可以设置内容居中：
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	option_1.pressed.connect(func(): _on_option_selected(0))
	option_2.pressed.connect(func(): _on_option_selected(1))
	option_3.pressed.connect(func(): _on_option_selected(2))
	skip_button.pressed.connect(_on_skip_pressed)

	if not LanguageManager.language_changed.is_connected(_refresh_text):
		LanguageManager.language_changed.connect(_refresh_text)
	
	setup_shop()
	_refresh_text()

# --- 核心逻辑 ---


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_language"):
		LanguageManager.toggle_language()
		get_viewport().set_input_as_handled()


func setup_shop() -> void:
	current_options.clear()
	
	# 随机生成3张牌 (each has a chance to be special)
	for i in range(3):
		if randf() < SPECIAL_TILE_CHANCE:
			var special = SPECIAL_TILES[randi() % SPECIAL_TILES.size()]
			current_options.append({"suit": special[0], "value": special[1]})
		else:
			var random_suit = randi() % 3  # 0:万, 1:筒, 2:条
			var random_value = (randi() % 9) + 1 # 1-9
			current_options.append({"suit": random_suit, "value": random_value})
	
	# 应用图片到按钮上
	_apply_tile_to_button(option_1, current_options[0])
	_apply_tile_to_button(option_2, current_options[1])
	_apply_tile_to_button(option_3, current_options[2])

	_refresh_text()

# 将随机出的数据转换为图片加载到按钮上
func _apply_tile_to_button(btn: Button, tile_data: Dictionary) -> void:
	var path := _get_tile_image_path(tile_data)
	var display_name := _get_tile_display_name(tile_data)
	
	if ResourceLoader.exists(path):
		var texture = load(path)
		btn.icon = texture
		btn.text = ""
	else:
		print("Warning: Tile image not found at -> ", path)
		btn.text = display_name
	
	btn.tooltip_text = _get_tile_tooltip(tile_data)

func _get_tile_image_path(tile_data: Dictionary) -> String:
	var suit: int = tile_data.get("suit", 0)
	var value: int = tile_data.get("value", 0)
	
	if suit <= 2:
		var num_str = PINYIN_NUMS[value]
		var suit_str = SUIT_NAMES[suit]
		return "res://assets/mahjung_tiles/three_suites/" + num_str + suit_str + ".png"
	
	for special in SPECIAL_TILES:
		if special[0] == suit and special[1] == value:
			return special[3]
	
	return ""

func _get_tile_display_name(tile_data: Dictionary) -> String:
	var suit: int = tile_data.get("suit", 0)
	var value: int = tile_data.get("value", 0)
	
	if suit <= 2:
		return PINYIN_NUMS[value] + SUIT_NAMES[suit]
	
	for special in SPECIAL_TILES:
		if special[0] == suit and special[1] == value:
			return special[2]
	
	return "?"

func _get_tile_tooltip(tile_data: Dictionary) -> String:
	var suit: int = tile_data.get("suit", 0)
	var value: int = tile_data.get("value", 0)
	
	if suit <= 2:
		return tr(SUIT_TOOLTIP_KEYS[suit])
	
	var special_key := _get_special_tooltip_key(suit, value)
	if special_key != "":
		return tr(special_key)
	
	return ""

func _get_special_tooltip_key(suit: int, value: int) -> String:
	match str(suit) + "_" + str(value):
		"3_0": return "shop_special_3_0"
		"3_1": return "shop_special_3_1"
		"3_2": return "shop_special_3_2"

		"4_0": return "shop_special_4_0"
		"4_1": return "shop_special_4_1"
		"4_2": return "shop_special_4_2"
		"4_3": return "shop_special_4_3"

		"5_0": return "shop_special_5_0"
		"5_1": return "shop_special_5_1"
		"5_2": return "shop_special_5_2"

		"6_0": return "shop_special_6_0"
		"6_1": return "shop_special_6_1"
		"6_2": return "shop_special_6_2"
		"6_3": return "shop_special_6_3"

		"7_0": return "shop_special_7_0"
		"7_1": return "shop_special_7_1"
		"7_2": return "shop_special_7_2"
		"7_3": return "shop_special_7_3"

		_: return ""

func _refresh_text() -> void:
	title_label.text = tr("shop_wave_clear")
	skip_button.text = tr("shop_skip")
	_refresh_tooltips()


func _refresh_tooltips() -> void:
	if current_options.size() >= 3:
		option_1.tooltip_text = _get_tile_tooltip(current_options[0])
		option_2.tooltip_text = _get_tile_tooltip(current_options[1])
		option_3.tooltip_text = _get_tile_tooltip(current_options[2])

# --- 交互事件 ---

func _on_option_selected(index: int) -> void:
	var chosen_tile = current_options[index]
	print("Player chose: ", _get_tile_display_name(chosen_tile))
	
	tile_chosen.emit(chosen_tile.suit, chosen_tile.value)
	_close_shop()

func _on_skip_pressed() -> void:
	print("Player skipped the reward.")
	_close_shop()

func _close_shop() -> void:
	get_tree().paused = false
	visible = false
