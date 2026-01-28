extends Data
class_name Move_data

enum X { LEFT, NONE, RIGHT }
enum Y { TOP, NONE, DOWN }

@export var _current_direction_deg: float = 0.0
@export var _current_math_deg: float = 0.0
@export var _current_speed: float = 0.0

@export var moved_distance: float = 0.0
@export var moved_time: float = 0.0

@export var moveX: X = X.NONE
@export var moveY: Y = Y.NONE

# --- internal ---
var _last_position: Vector2
var _has_last := false

func get_speed()->float: 
	return _current_speed 
	
func get_deg()->float: 
	return _current_direction_deg

func get_math_deg()->float: 
	return _current_math_deg
func get_last_position()->Vector2:
	return _last_position;

func print_data()->void:
	print("moved_distance",moved_distance);
	print("_current_math_deg",_current_math_deg);
	print("moveY",moveY);
	print("moveX",moveX);
	print("_current_direction_deg",_current_direction_deg);
	print("_last_position",_last_position);
func reset(pos: Vector2) -> void:
	_last_position = pos
	_has_last = true
	moved_distance = 0.0
	moved_time = 0.0
	_current_speed = 0.0
	_current_direction_deg = 0.0
	_current_math_deg = 0.0
	moveX = X.NONE
	moveY = Y.NONE


func record_motion(curr_pos: Vector2, delta: float) -> void:
	if delta <= 0.0:
		return

	var offset := curr_pos - _last_position
	_last_position = curr_pos;
	var dist := offset.length()

	# time & distance
	moved_time += delta
	moved_distance += dist

	# speed
	_current_speed = dist / delta

	# direction
	if dist > 0.0001:
		_current_direction_deg = rad_to_deg(offset.angle())
		_current_math_deg = fposmod(_current_direction_deg, 360.0)

		# X axis
		if offset.x > 0.0:
			moveX = X.RIGHT
		elif offset.x < 0.0:
			moveX = X.LEFT
		else:
			moveX = X.NONE

		# Y axis
		if offset.y > 0.0:
			moveY = Y.DOWN
		elif offset.y < 0.0:
			moveY = Y.TOP
		else:
			moveY = Y.NONE
	else:
		_current_speed = 0.0
		moveX = X.NONE
		moveY = Y.NONE
