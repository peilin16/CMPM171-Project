extends Shoot_configure
class_name Multi_shoot_configure

@export var interval :float = 1; # bullet interval
@export var num: int = 5;  #total num
@export var speed_arr: Array[float];# each bullet speed, not use speed of base gd
#setting 3
func _mutiple_configure(_interval:float, _num:int, from_speed: float = 0, to_speed: float = 0, _speed_arr:Array =[])->void:
	num = _num;
	interval = _interval;
	if from_speed == 0 and to_speed == 0 and _speed_arr.is_empty():
		for i in range(_num):
			speed_arr.push_back(speed);
	elif from_speed != 0 or to_speed != 0:
		_speed_setting(from_speed , to_speed );
	else:
		speed_arr = _speed_arr;
	

func _speed_setting(from_speed: float, to_speed: float) -> void:
	speed_arr.clear()

	if num <= 0:
		return
	# Only one bullet → use from_speed
	if num == 1:
		speed_arr.push_back(from_speed)
		return

	var step := (to_speed - from_speed) / float(num - 1)

	for i in range(num):
		var s := from_speed + step * i
		speed_arr.push_back(s)

func default_pattern() ->Pattern:
	return Multi_shoot_pattern.new();
