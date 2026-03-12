extends Control
class_name Start_menu
# 预加载第一个关卡，方便切换
const LEVEL_1_PATH = "res://scenes/Level/Level1.tscn"
var level: Level1_controller = null

const COLORBLIND_MODES := ["off", "protanopia", "deuteranopia", "tritanopia"]
const COLORBLIND_KEYS := [
	"colorblind_off",
	"colorblind_protanopia",
	"colorblind_deuteranopia",
	"colorblind_tritanopia"
]

@onready var colorblind_option: OptionButton = $AccessibilityContainer/ColorBlindOption
@onready var colorblind_label: Label = $AccessibilityContainer/ColorBlindLabel
var instruction_label: RichTextLabel

func _ready() -> void:
	instruction_label = get_node_or_null("InstructionPanel/InstructionLabel") as RichTextLabel
	# Only show start menu on Level 1
	if not get_parent() is Level1_controller:
		visible = false
		return
	# 确保一开始鼠标是可见的（以防游戏里隐藏了鼠标）
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	level = get_parent() as Level1_controller
	# 连接信号（也可以在编辑器界面的 Node 面板手动连接）
	if not $MenuContainer/StartButton.pressed.is_connected(_on_start_button_pressed):
		$MenuContainer/StartButton.pressed.connect(_on_start_button_pressed)
	if not $MenuContainer/QuitButton.pressed.is_connected(_on_quit_button_pressed):
		$MenuContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

	_setup_colorblind_option()
	if not LanguageManager.language_changed.is_connected(_refresh_text):
		LanguageManager.language_changed.connect(_refresh_text)
	_refresh_text()


func _setup_colorblind_option() -> void:
	colorblind_option.clear()

	for i in range(COLORBLIND_KEYS.size()):
		colorblind_option.add_item(tr(COLORBLIND_KEYS[i]), i)

	var current_mode: String = GameManager.get_colorblind_mode()
	var idx := COLORBLIND_MODES.find(current_mode)
	if idx >= 0:
		colorblind_option.select(idx)

	if not colorblind_option.item_selected.is_connected(_on_colorblind_selected):
		colorblind_option.item_selected.connect(_on_colorblind_selected)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_language"):
		LanguageManager.toggle_language()
		get_viewport().set_input_as_handled()


func _refresh_text() -> void:
	$MenuContainer/StartButton.text = tr("menu_new_game")
	$MenuContainer/QuitButton.text = tr("menu_quit_game")

	if colorblind_label:
		colorblind_label.text = tr("menu_colorblind_title")
	_setup_colorblind_option()

	if instruction_label:
		instruction_label.text = tr("menu_instructions")
	
func _on_start_button_pressed() -> void:
	# 切换到游戏关卡
	if GameManager.player_manager:
		GameManager.player_manager.clear_saved_mahjong_hand()
	if level != null and is_instance_valid(level):
		level.start_game()
	else:
		get_tree().change_scene_to_file(LEVEL_1_PATH)
func _on_quit_button_pressed() -> void:
	# 退出游戏
	get_tree().quit()

func _on_colorblind_selected(index: int) -> void:
	if index >= 0 and index < COLORBLIND_MODES.size():
		GameManager.set_colorblind_mode(COLORBLIND_MODES[index])
