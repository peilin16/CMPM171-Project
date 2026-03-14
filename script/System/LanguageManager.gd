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
	"Move with WASD.\nShoot automatically at nearby enemies.\nAvoid enemies and incoming bullets. Contact damage and bullet hits both cost HP.\nClear waves to reach the shop and build your Mahjong hand.\nYour Mahjong hand now mixes shot traits together.\nTiao (Bamboo): increases attack speed and adds burst repeats.\nTong (Circles): adds spread and fan shaping.\nWan (Characters): increases damage and keeps shots focused.\nSpecial tiles and completed sets unlock stronger pattern combinations and bonuses.\nPress T to switch languages.")

	en_translation.add_message("shop_skip", "Skip")
	en_translation.add_message("shop_tooltip_wan", "Wan: +1 damage per tile and favors focused single shots. Mixing suits unlocks combo patterns.")
	en_translation.add_message("shop_tooltip_tong", "Tong: pushes your hand toward spread and fan patterns. Matching numbers across suits unlocks extra combo patterns.")
	en_translation.add_message("shop_tooltip_tiao", "Tiao: +5% attack speed per tile and favors rapid multi-shot patterns. Runs across all 3 suits unlock extra combo patterns.")

	en_translation.add_message("shop_special_3_0", "Dora Wan: Counts as 2 Wan tiles (+damage).")
	en_translation.add_message("shop_special_3_1", "Dora Tong: Counts as 2 Tong tiles (stronger spread / fan patterns).")
	en_translation.add_message("shop_special_3_2", "Dora Tiao: Counts as 2 Tiao tiles (+attack speed).")

	en_translation.add_message("shop_special_4_0", "East Wind: +15% move speed. Collect all 4 Winds for a major mobility/defense combo.")
	en_translation.add_message("shop_special_4_1", "South Wind: +12% damage. Collect all 4 Winds for a major mobility/defense combo.")
	en_translation.add_message("shop_special_4_2", "West Wind: 15% damage reduction. Collect all 4 Winds for a major mobility/defense combo.")
	en_translation.add_message("shop_special_4_3", "North Wind: +15% attack speed. Collect all 4 Winds for a major mobility/defense combo.")

	en_translation.add_message("shop_special_5_0", "Red Dragon: +25% damage. Collect all 3 Dragons for a major offensive combo.")
	en_translation.add_message("shop_special_5_1", "Green Dragon: +25% score gain. Collect all 3 Dragons for a major offensive combo.")
	en_translation.add_message("shop_special_5_2", "White Dragon: +15% bullet speed. Collect all 3 Dragons for a major offensive combo.")

	en_translation.add_message("shop_special_6_0", "Plum: +8% attack speed. Collect all 4 Flowers for a utility combo.")
	en_translation.add_message("shop_special_6_1", "Orchid: +8% move speed. Collect all 4 Flowers for a utility combo.")
	en_translation.add_message("shop_special_6_2", "Bamboo: +10% bullet speed. Collect all 4 Flowers for a utility combo.")
	en_translation.add_message("shop_special_6_3", "Chrysanthemum: +8% damage. Collect all 4 Flowers for a utility combo.")

	en_translation.add_message("shop_special_7_0", "Spring: +10% attack speed. Collect all 4 Seasons for a tempo combo.")
	en_translation.add_message("shop_special_7_1", "Summer: +10% damage. Collect all 4 Seasons for a tempo combo.")
	en_translation.add_message("shop_special_7_2", "Fall: +8% bullet speed. Collect all 4 Seasons for a tempo combo.")
	en_translation.add_message("shop_special_7_3", "Winter: +10% move speed. Collect all 4 Seasons for a tempo combo.")


	en_translation.add_message("pause_title", "PAUSED")
	en_translation.add_message("pause_resume", "Resume")
	en_translation.add_message("pause_restart", "Restart")
	en_translation.add_message("pause_title_screen", "Title Screen")

	en_translation.add_message("shop_wave_clear", "Wave Cleared. Click & continue with your favorite mahjong tile!")

	en_translation.add_message("game_over_level", "Current Level: {level}")




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
	"使用 WASD 上下左右移动。\n会自动向附近敌人射击。\n躲避敌人和敌方弹幕。接触敌人或被子弹击中都会损失生命值。\n清完波次后可以进入商店，补充你的麻将牌组。\n你的麻将手牌现在会把不同射击特性混合在一起。\n条子：提升攻速，并增加连发次数。\n筒子：增加扩散与扇形效果。\n万子：提升伤害，并让射击更集中。\n特殊牌与成套组合会触发更强的弹幕组合与连携增益。\n按 T 键切换语言。")

	zh_translation.add_message("shop_skip", "跳过")
	zh_translation.add_message("shop_tooltip_wan", "万：每张增加 1 点伤害，并偏向单点集中射击。混合花色可解锁组合弹幕。")
	zh_translation.add_message("shop_tooltip_tong", "筒：让你的手牌更偏向扩散与扇形模式。不同花色的相同数字可解锁额外组合效果。")
	zh_translation.add_message("shop_tooltip_tiao", "条：每张增加 5% 攻速，并偏向快速多段射击。三种花色连续组合可解锁额外组合效果。")

	zh_translation.add_message("shop_special_3_0", "宝牌万：按 2 张万子计算（提升伤害）。")
	zh_translation.add_message("shop_special_3_1", "宝牌筒：按 2 张筒子计算（更强的扩散 / 扇形模式）。")
	zh_translation.add_message("shop_special_3_2", "宝牌条：按 2 张条子计算（提升攻速）。")

	zh_translation.add_message("shop_special_4_0", "东风：移动速度 +15%。集齐四风牌可触发强力的机动 / 防御组合。")
	zh_translation.add_message("shop_special_4_1", "南风：伤害 +12%。集齐四风牌可触发强力的机动 / 防御组合。")
	zh_translation.add_message("shop_special_4_2", "西风：伤害减免 15%。集齐四风牌可触发强力的机动 / 防御组合。")
	zh_translation.add_message("shop_special_4_3", "北风：攻击速度 +15%。集齐四风牌可触发强力的机动 / 防御组合。")

	zh_translation.add_message("shop_special_5_0", "红中：伤害 +25%。集齐三元牌可触发强力的进攻组合。")
	zh_translation.add_message("shop_special_5_1", "发财：分数收益 +25%。集齐三元牌可触发强力的进攻组合。")
	zh_translation.add_message("shop_special_5_2", "白板：子弹速度 +15%。集齐三元牌可触发强力的进攻组合。")

	zh_translation.add_message("shop_special_6_0", "梅：攻击速度 +8%。集齐四花牌可触发功能型组合。")
	zh_translation.add_message("shop_special_6_1", "兰：移动速度 +8%。集齐四花牌可触发功能型组合。")
	zh_translation.add_message("shop_special_6_2", "竹：子弹速度 +10%。集齐四花牌可触发功能型组合。")
	zh_translation.add_message("shop_special_6_3", "菊：伤害 +8%。集齐四花牌可触发功能型组合。")

	zh_translation.add_message("shop_special_7_0", "春：攻击速度 +10%。集齐四季牌可触发节奏型组合。")
	zh_translation.add_message("shop_special_7_1", "夏：伤害 +10%。集齐四季牌可触发节奏型组合。")
	zh_translation.add_message("shop_special_7_2", "秋：子弹速度 +8%。集齐四季牌可触发节奏型组合。")
	zh_translation.add_message("shop_special_7_3", "冬：移动速度 +10%。集齐四季牌可触发节奏型组合。")


	zh_translation.add_message("pause_title", "已暂停")
	zh_translation.add_message("pause_resume", "继续游戏")
	zh_translation.add_message("pause_restart", "重新开始")
	zh_translation.add_message("pause_title_screen", "返回标题")

	zh_translation.add_message("shop_wave_clear", "波次已清除。点击你喜欢的麻将牌继续前进！")

	zh_translation.add_message("game_over_level", "当前关卡：{level}")


	



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
	"WASDキーで移動します。\n近くの敵へ自動で弾を撃ちます。\n敵本体と敵弾の両方に注意してください。接触や被弾でHPが減少します。\nウェーブを突破するとショップで麻雀牌を追加できます。\n手牌の効果は組み合わせてショットに反映されます。\n索子（ソーズ）：攻撃速度を上げ、連射バーストを追加します。\n筒子（ピンズ）：拡散や扇形の性質を追加します。\n萬子（マンズ）：ダメージを上げ、ショットを集中寄りにします。\n特殊牌や完成したセットで、より強い弾幕の組み合わせとコンボ効果が発動します。\nTキーで言語を切り替えます。")

	ja_translation.add_message("shop_skip", "スキップ")
	ja_translation.add_message("shop_tooltip_wan", "萬子：1枚ごとにダメージが+1され、単発集中型の射撃に向きます。異なる種類を混ぜるとコンボ弾幕が解放されます。")
	ja_translation.add_message("shop_tooltip_tong", "筒子：手牌が拡散・扇形ショット寄りになります。異なる種類で同じ数字を揃えると追加コンボが解放されます。")
	ja_translation.add_message("shop_tooltip_tiao", "索子：1枚ごとに攻撃速度が5%上昇し、高速多段射撃に向きます。3種類をまたぐ連番で追加コンボが解放されます。")

	ja_translation.add_message("shop_special_3_0", "ドラ萬子：萬子2枚分として扱われます（ダメージ強化）。")
	ja_translation.add_message("shop_special_3_1", "ドラ筒子：筒子2枚分として扱われます（より強い拡散 / 扇形パターン）。")
	ja_translation.add_message("shop_special_3_2", "ドラ索子：索子2枚分として扱われます（攻撃速度上昇）。")

	ja_translation.add_message("shop_special_4_0", "東：移動速度 +15%。風牌4種を揃えると、強力な機動 / 防御コンボが発動します。")
	ja_translation.add_message("shop_special_4_1", "南：ダメージ +12%。風牌4種を揃えると、強力な機動 / 防御コンボが発動します。")
	ja_translation.add_message("shop_special_4_2", "西：被ダメージ 15% 軽減。風牌4種を揃えると、強力な機動 / 防御コンボが発動します。")
	ja_translation.add_message("shop_special_4_3", "北：攻撃速度 +15%。風牌4種を揃えると、強力な機動 / 防御コンボが発動します。")

	ja_translation.add_message("shop_special_5_0", "中：ダメージ +25%。三元牌を揃えると、強力な攻撃コンボが発動します。")
	ja_translation.add_message("shop_special_5_1", "發：スコア獲得量 +25%。三元牌を揃えると、強力な攻撃コンボが発動します。")
	ja_translation.add_message("shop_special_5_2", "白：弾速 +15%。三元牌を揃えると、強力な攻撃コンボが発動します。")

	ja_translation.add_message("shop_special_6_0", "梅：攻撃速度 +8%。花牌4種を揃えると、ユーティリティ系コンボが発動します。")
	ja_translation.add_message("shop_special_6_1", "蘭：移動速度 +8%。花牌4種を揃えると、ユーティリティ系コンボが発動します。")
	ja_translation.add_message("shop_special_6_2", "竹：弾速 +10%。花牌4種を揃えると、ユーティリティ系コンボが発動します。")
	ja_translation.add_message("shop_special_6_3", "菊：ダメージ +8%。花牌4種を揃えると、ユーティリティ系コンボが発動します。")

	ja_translation.add_message("shop_special_7_0", "春：攻撃速度 +10%。季節牌4種を揃えると、テンポ系コンボが発動します。")
	ja_translation.add_message("shop_special_7_1", "夏：ダメージ +10%。季節牌4種を揃えると、テンポ系コンボが発動します。")
	ja_translation.add_message("shop_special_7_2", "秋：弾速 +8%。季節牌4種を揃えると、テンポ系コンボが発動します。")
	ja_translation.add_message("shop_special_7_3", "冬：移動速度 +10%。季節牌4種を揃えると、テンポ系コンボが発動します。")


	ja_translation.add_message("pause_title", "一時停止")
	ja_translation.add_message("pause_resume", "再開")
	ja_translation.add_message("pause_restart", "リスタート")
	ja_translation.add_message("pause_title_screen", "タイトルへ戻る")

	ja_translation.add_message("shop_wave_clear", "ウェーブクリア。好きな麻雀牌を選んで次へ進みましょう！")

	ja_translation.add_message("game_over_level", "現在のレベル：{level}")


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
