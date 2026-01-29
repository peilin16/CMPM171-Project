extends Item
class_name Mahjong


# 定义花色枚举
enum Suit {
	BAMBOO,     # 0: 条子 (敏捷/频率)
	DOT,        # 1: 筒子 (范围/力量)
	CHARACTER,  # 2: 万字 (暴击/经济)
	WIND,       # 3: 风牌
	DRAGON      # 4: 箭牌/三元牌
}

# 导出变量，方便在编辑器里直接设置这张牌是什么
@export_category("Mahjong Stats")
@export var suit: Suit = Suit.BAMBOO  # 默认为条子
@export_range(1, 9) var rank: int = 1 # 牌面数值 (1-9)

# 调试信息
func get_tile_name() -> String:
	var suit_names = ["Bamboo", "Dot", "Character", "Wind", "Dragon"]
	return suit_names[suit] + "_" + str(rank)