extends Node

signal language_changed

const LOCALE_EN := "en"
const LOCALE_ZH := "zh_CN"
const LOCALE_JA := "ja"

const LANGUAGE_ORDER := [LOCALE_EN, LOCALE_ZH, LOCALE_JA]

var current_locale: String = LOCALE_EN

var en_translation: Translation
var zh_translation: Translation
var ja_translation: Translation


func _ready() -> void:
	_create_translations()

	TranslationServer.add_translation(en_translation)
	TranslationServer.add_translation(zh_translation)
	TranslationServer.add_translation(ja_translation)

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

	en_translation.add_message("menu_colorblind_title", "Color-Blind Filter")
	en_translation.add_message("colorblind_off", "Off")
	en_translation.add_message("colorblind_protanopia", "Protanopia")
	en_translation.add_message("colorblind_deuteranopia", "Deuteranopia")
	en_translation.add_message("colorblind_tritanopia", "Tritanopia")

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

	zh_translation.add_message("menu_colorblind_title", "色盲滤镜")
	zh_translation.add_message("colorblind_off", "关闭")
	zh_translation.add_message("colorblind_protanopia", "红色盲")
	zh_translation.add_message("colorblind_deuteranopia", "绿色盲")
	zh_translation.add_message("colorblind_tritanopia", "蓝色盲")

	# Japanese
	ja_translation = Translation.new()
	ja_translation.locale = LOCALE_JA
	ja_translation.add_message("menu_new_game", "ゲーム開始")
	ja_translation.add_message("menu_quit_game", "ゲーム終了")

	ja_translation.add_message("game_over_title", "ゲームオーバー")
	ja_translation.add_message("game_over_score", "最終スコア：{score}")
	ja_translation.add_message("game_over_waves", "生存ウェーブ数：{waves}")
	ja_translation.add_message("game_over_restart", "リスタート")
	ja_translation.add_message("game_over_title_screen", "タイトルへ戻る")

	ja_translation.add_message("menu_colorblind_title", "色覚フィルター")
	ja_translation.add_message("colorblind_off", "オフ")
	ja_translation.add_message("colorblind_protanopia", "1型色覚")
	ja_translation.add_message("colorblind_deuteranopia", "2型色覚")
	ja_translation.add_message("colorblind_tritanopia", "3型色覚")


func toggle_language() -> void:
	var current_index := LANGUAGE_ORDER.find(current_locale)

	if current_index == -1:
		set_language(LOCALE_EN)
		return

	var next_index := (current_index + 1) % LANGUAGE_ORDER.size()
	set_language(LANGUAGE_ORDER[next_index])


func set_language(locale: String) -> void:
	current_locale = locale
	TranslationServer.set_locale(locale)
	language_changed.emit()


func get_current_locale() -> String:
	return current_locale


func is_chinese() -> bool:
	return current_locale == LOCALE_ZH