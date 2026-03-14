extends Control
class_name Pause_menu

const START_MENU_PATH = "res://scenes/Level/Level1.tscn"

@onready var title_label: Label = $CenterContainer/VBoxContainer/Label
@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)

	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

	if not LanguageManager.language_changed.is_connected(_refresh_text):
		LanguageManager.language_changed.connect(_refresh_text)

	_refresh_text()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_language"):
		LanguageManager.toggle_language()
		get_viewport().set_input_as_handled()


func _refresh_text() -> void:
	title_label.text = tr("pause_title")
	resume_button.text = tr("pause_resume")
	restart_button.text = tr("pause_restart")
	quit_button.text = tr("pause_title_screen")


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_restart_pressed() -> void:
	get_tree().paused = false
	if GameManager.player_manager:
		GameManager.player_manager.clear_saved_mahjong_hand()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	if GameManager.player_manager:
		GameManager.player_manager.clear_saved_mahjong_hand()
	get_tree().change_scene_to_file(START_MENU_PATH)
