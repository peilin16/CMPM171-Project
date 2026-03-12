extends Wave_director
class_name Level1_wave_director

func _ready() -> void:
	next_level_scenes = "res://scenes/Level/Level2.tscn";

func config_waves() -> void:
	_generate_infinite_waves()
