extends Resource
class_name Character_logic

var controller;
var character:Character;

func _init(_controller, _character: Character) -> void:
	controller = _controller;
	character = _character
func behit(bullet: Bullet)-> void:
	pass
