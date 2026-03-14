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
@onready var instructions_button: Button = $MenuContainer/InstructionsButton
var instruction_label: RichTextLabel
var instruction_panel: Panel
var instruction_title: Label
var instruction_close_button: Button

func _ready() -> void:
	instruction_panel = get_node_or_null("InstructionPanel") as Panel
	instruction_title = get_node_or_null("InstructionPanel/InstructionTitle") as Label
	instruction_label = get_node_or_null("InstructionPanel/InstructionLabel") as RichTextLabel
	instruction_close_button = get_node_or_null("InstructionPanel/CloseButton") as Button
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
	if instructions_button and not instructions_button.pressed.is_connected(_on_instructions_button_pressed):
		instructions_button.pressed.connect(_on_instructions_button_pressed)
	if instruction_close_button and not instruction_close_button.pressed.is_connected(_on_close_instructions_pressed):
		instruction_close_button.pressed.connect(_on_close_instructions_pressed)
	_set_instruction_popup_visible(false)

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
	if instruction_panel and instruction_panel.visible and event.is_action_pressed("ui_cancel"):
		_set_instruction_popup_visible(false)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("toggle_language"):
		LanguageManager.toggle_language()
		get_viewport().set_input_as_handled()


func _refresh_text() -> void:
	$MenuContainer/StartButton.text = tr("menu_new_game")
	$MenuContainer/QuitButton.text = tr("menu_quit_game")
	if instructions_button:
		instructions_button.text = tr("menu_instructions_button")

	if colorblind_label:
		colorblind_label.text = tr("menu_colorblind_title")
	_setup_colorblind_option()

	if instruction_title:
		instruction_title.text = tr("menu_instructions_title")
	if instruction_label:
		instruction_label.text = tr("menu_instructions")
	if instruction_close_button:
		instruction_close_button.text = tr("menu_close")
	
func _on_start_button_pressed() -> void:
	# 切换到游戏关卡
	_set_instruction_popup_visible(false)
	if GameManager:
		GameManager.reset_run_state()
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

func _on_instructions_button_pressed() -> void:
	_set_instruction_popup_visible(true)

func _on_close_instructions_pressed() -> void:
	_set_instruction_popup_visible(false)

func _set_instruction_popup_visible(is_visible: bool) -> void:
	if instruction_panel:
		instruction_panel.visible = is_visible
