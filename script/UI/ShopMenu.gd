extends Control
class_name Shop_menu
signal tile_chosen(suit: int, value: int)

@onready var option_1: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/TileContainer/Option1
@onready var option_2: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/TileContainer/Option2
@onready var option_3: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/TileContainer/Option3
@onready var skip_button: Button = $CenterContainer/Panel/MainHBox/VBoxContainer/SkipButton

var current_options: Array = []

# --- 核心：拼音映射表 ---
# 用于将数字 1-9 和花色 0-2 转换为美术文件的名字
const PINYIN_NUMS = ["", "yi", "er", "san", "si", "wu", "liu", "qi", "ba", "jiu"]
const SUIT_NAMES = ["wan", "tong", "tiao"]

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
	
	setup_shop()

# --- 核心逻辑 ---

func setup_shop() -> void:
	current_options.clear()
	
	# 随机生成3张牌
	for i in range(3):
		var random_suit = randi() % 3  # 0:万, 1:筒, 2:条
		var random_value = (randi() % 9) + 1 # 1-9
		current_options.append({"suit": random_suit, "value": random_value})
	
	# 应用图片到按钮上
	_apply_tile_to_button(option_1, current_options[0])
	_apply_tile_to_button(option_2, current_options[1])
	_apply_tile_to_button(option_3, current_options[2])

# 将随机出的数据转换为图片加载到按钮上
func _apply_tile_to_button(btn: Button, tile_data: Dictionary) -> void:
	# 拼接文件名，例如： "yi" + "wan" + ".png" -> "yiwan.png"
	var num_str = PINYIN_NUMS[tile_data.value]
	var suit_str = SUIT_NAMES[tile_data.suit]
	var file_name = num_str + suit_str + ".png"
	
	# 拼接完整路径 (请确保这个路径和你 Godot 里的实际路径一致)
	var path = "res://assets/mahjung_tiles/three_suites/" + file_name
	
	if ResourceLoader.exists(path):
		var texture = load(path)
		btn.icon = texture
		btn.text = "" # 找到了图片，就清空原本的测试文字
	else:
		print("Warning: Tile image not found at -> ", path)
		# 如果找不到图片（可能是路径不对），降级显示拼音文字
		btn.text = num_str + suit_str

# --- 交互事件 ---

func _on_option_selected(index: int) -> void:
	var chosen_tile = current_options[index]
	var tile_name = PINYIN_NUMS[chosen_tile.value] + SUIT_NAMES[chosen_tile.suit]
	print("Player chose: ", tile_name)
	
	tile_chosen.emit(chosen_tile.suit, chosen_tile.value)
	_close_shop()

func _on_skip_pressed() -> void:
	print("Player skipped the reward.")
	_close_shop()

func _close_shop() -> void:
	get_tree().paused = false
	visible = false
