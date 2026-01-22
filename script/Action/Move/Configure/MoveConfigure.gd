# MoveConfigureBase.gd
extends Configure
class_name Move_configure


@export var max_velocity: float = 120.0
@export var wave: float = 0.0
# -1 means disabled
@export var acceleration: float = -1.0
@export var deceleration: float = -1.0

# runtime start position (auto set by runner)
@export var start: Vector2 = Vector2.ZERO

func _init() -> void:
	belong = Belong.MOVE


func default_pattern() ->Pattern:
	return Linear_move_pattern.new();
		
	

func dir_to_angle_deg(dire: Vector2) -> float:
	return rad_to_deg(dire.angle())

func normalize_angle(angle_deg: float) -> float:
	return fposmod(angle_deg, 360.0)
