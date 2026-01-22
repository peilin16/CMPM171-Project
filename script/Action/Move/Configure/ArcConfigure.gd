# ArcMoveConfigure.gd
extends Target_move_configure
class_name Arc_move_configure

# 控制点（顶点）。为 ZERO 则自动生成一个“好看”的点
@export var vertex: Vector2 = Vector2.ZERO

# 采样精度（越大越准，越耗一点点预计算）
@export var sample_count: int = 60

# 曲线偏移（当 vertex == ZERO 时用它生成控制点）
@export var auto_height: float = 120.0
@export var auto_side: float = 0.0   # 允许侧向偏移（做左/右弧）

func setup_arc(_vertex: Vector2 = Vector2.ZERO, _sample_count: int = 60)->void:
	sample_count = _sample_count;
	vertex = _vertex;
func default_pattern() ->Pattern:
	return Arc_move_pattern.new();
