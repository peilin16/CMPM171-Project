extends Node
class_name LevelManager

@export var current_level :Level_controller;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func setup(level:Level_controller)->void:
	current_level = level; 
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
