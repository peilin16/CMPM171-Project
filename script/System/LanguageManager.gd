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
	en_translation.add_message("menu_instructions_button", "Instructions")
	en_translation.add_message("menu_instructions_title", "How to Play")
	en_translation.add_message("menu_close", "Close")

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

	en_translation.add_message("menu_instructions",
	"Move with WASD.\nFire with the Left Mouse Button.\nAvoid enemies and incoming bullets. Contact damage and bullet hits both cost HP.\nClear waves to reach the shop and build your Mahjong hand.\nYour Mahjong hand now determines your shot pattern.\nTiao (Bamboo): increases attack speed and favors rapid multi-shot fire.\nTong (Circles): pushes your shots toward spread and fan patterns.\nWan (Characters): increases damage and favors focused shots.\nSpecial tiles and completed sets unlock stronger combo patterns and bonuses.\nPress T to switch languages.")

	# Chinese
	zh_translation = Translation.new()
	zh_translation.locale = LOCALE_ZH
	zh_translation.add_message("menu_new_game", "开始游戏")
	zh_translation.add_message("menu_quit_game", "退出游戏")
	zh_translation.add_message("menu_instructions_button", "游戏说明")
	zh_translation.add_message("menu_instructions_title", "玩法说明")
	zh_translation.add_message("menu_close", "关闭")

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

	zh_translation.add_message("menu_instructions",
	"使用 WASD 上下左右移动。\n使用鼠标左键发射子弹。\n躲避敌人和敌方弹幕。接触敌人或被子弹击中都会损失生命值。\n清完波次后可以进入商店，补充你的麻将牌组。\n你的整副麻将手牌现在会决定射击模式。\n条子：提升攻速，并更偏向连续多发。\n筒子：让射击更偏向扩散与扇形。\n万子：提升伤害，并更偏向集中射击。\n特殊牌与成套组合会触发更强的弹幕形态与连携增益。\n按 T 键切换语言。")

	# Japanese
	ja_translation = Translation.new()
	ja_translation.locale = LOCALE_JA
	ja_translation.add_message("menu_new_game", "ゲーム開始")
	ja_translation.add_message("menu_quit_game", "ゲーム終了")
	ja_translation.add_message("menu_instructions_button", "遊び方")
	ja_translation.add_message("menu_instructions_title", "操作説明")
	ja_translation.add_message("menu_close", "閉じる")

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
	ja_translation.add_message("menu_instructions",
	"WASDキーで移動します。\nマウス左クリックで弾を撃ちます。\n敵本体と敵弾の両方に注意してください。接触や被弾でHPが減少します。\nウェーブを突破するとショップで麻雀牌を追加できます。\n手牌全体でショットパターンが決まるようになりました。\n索子（ソーズ）：攻撃速度が上がり、連射寄りになります。\n筒子（ピンズ）：拡散や扇形ショット寄りになります。\n萬子（マンズ）：ダメージが上がり、集中ショット寄りになります。\n特殊牌や完成したセットで、より強い弾幕パターンとコンボ効果が発動します。\nTキーで言語を切り替えます。")

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