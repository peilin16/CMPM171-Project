extends Node

signal language_changed

const LOCALE_EN := "en"
const LOCALE_ZH := "zh_CN"

var current_locale: String = LOCALE_EN

var en_translation: Translation
var zh_translation: Translation


func _ready() -> void:
	_create_translations()

	TranslationServer.add_translation(en_translation)
	TranslationServer.add_translation(zh_translation)

	set_language(LOCALE_EN)


func _create_translations() -> void:
	# English
	en_translation = Translation.new()
	en_translation.locale = LOCALE_EN
	en_translation.add_message("menu_new_game", "New Game")
	en_translation.add_message("menu_quit_game", "Quit Game")

	en_translation.add_message("game_over_title", "GAME OVER")
	en_translation.add_message("game_over_score", "Final Score: {score}")
	en_translation.add_message("game_over_waves", "Waves Survived: {waves}")
	en_translation.add_message("game_over_restart", "Restart")
	en_translation.add_message("game_over_title_screen", "Title Screen")

	# Chinese
	zh_translation = Translation.new()
	zh_translation.locale = LOCALE_ZH
	zh_translation.add_message("menu_new_game", "开始游戏")
	zh_translation.add_message("menu_quit_game", "退出游戏")

	zh_translation.add_message("game_over_title", "游戏结束")
	zh_translation.add_message("game_over_score", "最终得分：{score}")
	zh_translation.add_message("game_over_waves", "生存波数：{waves}")
	zh_translation.add_message("game_over_restart", "重新开始")
	zh_translation.add_message("game_over_title_screen", "返回标题")


func toggle_language() -> void:
	if current_locale == LOCALE_EN:
		set_language(LOCALE_ZH)
	else:
		set_language(LOCALE_EN)


func set_language(locale: String) -> void:
	current_locale = locale
	TranslationServer.set_locale(locale)
	language_changed.emit()


func get_current_locale() -> String:
	return current_locale


func is_chinese() -> bool:
	return current_locale == LOCALE_ZH