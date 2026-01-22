extends System
class_name Configure

@export var command_id: int;
var controller;



func _init() -> void:
	pass

func _ready() ->void:
	pass

func default_pattern() ->Pattern:
	return Pattern.new();
