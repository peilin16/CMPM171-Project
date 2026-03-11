
extends Control

const START_MENU_PATH = "res://scenes/Level/Level1.tscn"

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

var final_score: int = 0
var survived_waves: int = 0

func _ready() -> void:
# 同样确保处理模式正确，如果 Game Over 是通过暂停游戏来实现的
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

	if not LanguageManager.language_changed.is_connected(_refresh_text):
		LanguageManager.language_changed.connect(_refresh_text)
	_refresh_text();
	#
#func show_menu()->void:
	
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_language"):
		LanguageManager.toggle_language()
		get_viewport().set_input_as_handled()


func _refresh_text() -> void:
	title_label.text = tr("game_over_title")
	restart_button.text = tr("game_over_restart")
	quit_button.text = tr("game_over_title_screen")

	score_label.text = tr("game_over_score").format({
		"score": GameManager.player_manager.player_score
	})
	wave_label.text ="Level :"+ GameManager.level_manager.get_level_name()
	

# --- [API] 供外部调用的设置函数 ---
# 这里的参数可以根据你们之后的数据结构扩展
func set_stats(score: int, waves: int) -> void:
	final_score = score
	survived_waves = waves
	_refresh_text()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(START_MENU_PATH)


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(START_MENU_PATH)
