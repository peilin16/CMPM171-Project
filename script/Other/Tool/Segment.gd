extends Resource
class_name Segment
@export var _start:Vector2;
@export var _end:Vector2;
@export var _distance:float;
@export var _speed: float = 0.0   # speed along this segment
func _init(start:Vector2,end:Vector2 )->void:
	_start = start;
	_end = end;
	_distance = _start.distance_to(_end);
func get_distance() ->float:
	return _distance;	
