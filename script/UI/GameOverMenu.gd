extends Control

const START_MENU_PATH = "res://scenes/UI/StartMenu.tscn"

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel

func _ready() -> void:
	# 同样确保处理模式正确，如果 Game Over 是通过暂停游戏来实现的
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$Panel/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

# --- [API] 供外部调用的设置函数 ---
# 这里的参数可以根据你们之后的数据结构扩展
func set_stats(score: int, waves: int) -> void:
	score_label.text = "Final Score: %d" % score
	wave_label.text = "Waves Survived: %d" % waves

func _on_restart_pressed() -> void:
<<<<<<< Updated upstream
	get_tree().paused = false
	get_tree().reload_current_scene()
=======
	get_tree().paused = false 
	get_tree().change_scene_to_file(START_MENU_PATH)
>>>>>>> Stashed changes

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(START_MENU_PATH)
