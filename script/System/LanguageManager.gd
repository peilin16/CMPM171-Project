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

	en_translation.add_message("menu_instructions",
	"Use the mouse wheel to scroll down for more.\nUse WASD to move up, down, left, and right.\nUse the Left Mouse Button to fire bullets.\nDodge enemies and incoming bullets. Taking a hit from a bullet or touching an enemy will reduce your health.\nKill enemies to earn points to buy Mahjong tiles.\nDifferent Mahjong tiles grant different buffs:\nBamboo tiles (Souzu): Increase fire rate.\nCircle tiles (Pinzu): Change the number of bullets fired.\nCharacter tiles (Manzu): Increase attack power.\nCollecting specific tile combinations will trigger even stronger effects.\nPress the T key to switch languages (English - Chinese - Japanese).")

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

	zh_translation.add_message("menu_instructions",
	"使用鼠标滚轮向下滚动查看更多内容。\n使用 WASD 上下左右移动。\n使用鼠标左键发射子弹。\n躲避敌人和敌人的子弹。被子弹击中或碰到敌人都会扣血。\n击杀敌人可获得分数，并使用分数购买麻将牌。\n不同麻将牌会提供不同增益：\n条子：增加射速。\n筒子：改变发射子弹的数量。\n万子：增加攻击力。\n收集特定牌型组合后，会触发更强力的效果。\n按 T 键可切换语言（英文 - 中文 - 日文）。")

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
	ja_translation.add_message("menu_instructions",
	"マウスホイールを下にスクロールして続きをご覧ください。\nWASDキーで上下左右に移動します。\nマウスの左クリックで弾を発射します。\n敵と敵の弾を避けてください。被弾したり、敵に触れたりするとHPが減少します。\n敵を倒してスコアを獲得し、そのスコアで麻雀牌を購入できます。\n麻雀牌の種類によって異なる強化効果が得られます：\n索子（ソーズ）：発射速度が上昇します。\n筒子（ピンズ）：発射する弾の数が変化します。\n萬子（マンズ）：攻撃力が上昇します。\n特定の牌の組み合わせを揃えると、さらに強力な効果が発動します。\nTキーを押すと、言語を切り替えることができます（英語 - 中国語 - 日本語）。")

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