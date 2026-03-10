extends Control
class_name Start_menu
# 预加载第一个关卡，方便切换
const LEVEL_1_PATH = "res://scenes/Level/Level1.tscn"
var level:Level1_controller;
func _ready() -> void:
	# 确保一开始鼠标是可见的（以防游戏里隐藏了鼠标）
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	level=get_parent();
	# 连接信号（也可以在编辑器界面的 Node 面板手动连接）
	if not $MenuContainer/StartButton.pressed.is_connected(_on_start_button_pressed):
		$MenuContainer/StartButton.pressed.connect(_on_start_button_pressed)
	if not $MenuContainer/QuitButton.pressed.is_connected(_on_quit_button_pressed):
		$MenuContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

	LanguageManager.language_changed.connect(_refresh_text)
	_refresh_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_language"):
		LanguageManager.toggle_language()
		get_viewport().set_input_as_handled()


func _refresh_text() -> void:
	$MenuContainer/StartButton.text = tr("menu_new_game")
	$MenuContainer/QuitButton.text = tr("menu_quit_game")



	
func _on_start_button_pressed() -> void:
	# 切换到游戏关卡
	#get_tree().change_scene_to_file(LEVEL_1_PATH)
	level.start_game();
func _on_quit_button_pressed() -> void:
	# 退出游戏
	get_tree().quit()

