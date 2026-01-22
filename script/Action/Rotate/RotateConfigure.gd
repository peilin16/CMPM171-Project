# Rotate_configure.gd
extends Configure
class_name Rotate_configure

# math degrees (CCW+): 0 right, 90 up
@export var start_deg: float = 0.0

# degrees per second, always positive
@export var max_speed_deg: float = 120.0


@export var acceleration:float = -1;#if -1 no acceleration
@export var deceleration:float = -1; #if -1 no deceleration

# true = clockwise (visual), false = CCW (math positive)
@export var is_clockwise: bool = true

# stop tolerance
@export var epsilon_deg: float = 0.5

func _init() -> void:
	belong = System.Belong.ROTATE;

func _wrap_positive_deg(d: float) -> float:
	# convert negative input into [0,360)
	return fposmod(d, 360.0)

func _wrap_deg(d: float) -> float:
	var r := fposmod(d, 360.0)
	return r

func default_pattern()-> Pattern:
	return Rotate_pattern.new();
