extends Control

# 预加载第一个关卡，方便切换
const LEVEL_1_PATH = "res://scenes/Level/Level1.tscn"

func _ready() -> void:
	# 确保一开始鼠标是可见的（以防游戏里隐藏了鼠标）
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 连接信号（也可以在编辑器界面的 Node 面板手动连接）
	$MenuContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$MenuContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	# 切换到游戏关卡
	get_tree().change_scene_to_file(LEVEL_1_PATH)

func _on_quit_button_pressed() -> void:
	# 退出游戏
	get_tree().quit()
