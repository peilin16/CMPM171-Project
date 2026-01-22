extends Node
class_name LevelManager

@export var current_level = test_level.new();
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level._init();
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
