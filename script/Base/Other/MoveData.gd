extends Resource
class_name Move_data


@export var _current_direction_deg: float=0.0; #current_direction use for move pattern
@export var _current_speed :float = 0.0;#current speed use for move pattern
@export var moved_distance:float = 0.0;
@export var moved_time:float;
@export var _current_direction:Vector2;
@export var _current_position:Vector2;
#task runner only
func set_speed(s:float)->void:
	_current_speed = s
func set_deg(d:float)->void:
	_current_direction_deg = d

func get_speed()->float:
	return _current_speed
func get_deg()->float:
	return _current_direction_deg
