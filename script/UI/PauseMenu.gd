extends Control
class_name Pause_menu
# 预加载主菜单和当前关卡（方便重启）
const START_MENU_PATH = "res://scenes/Level/Level1.tscn"
# 注意：正式版可能需要动态获取当前关卡，这里暂时写死或者留空
const LEVEL_1_PATH = "res://scenes/Level/Level1.tscn"

func _ready() -> void:
	# 默认隐藏，或者由 GameManager 实例化时控制
	# visible = false 
	
	$CenterContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_resume_pressed() -> void:
	# 解除暂停
	get_tree().paused = false
	self.visible = false

func _on_restart_pressed() -> void:
	# 重启前务必先解除暂停，否则新场景加载出来也是暂停的！
	get_tree().paused = false
	if GameManager.player_manager:
		GameManager.player_manager.clear_saved_mahjong_hand()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	if GameManager.player_manager:
		GameManager.player_manager.clear_saved_mahjong_hand()
	get_tree().change_scene_to_file(START_MENU_PATH)
