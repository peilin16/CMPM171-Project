extends Resource
class_name Animation_object


@export var animation_name: String
@export var animation_speed: float = 1.0
@export var is_loop: bool = false

func _init() -> void:
	animation_speed = 1;
	is_loop = false;
	animation_name = "";
