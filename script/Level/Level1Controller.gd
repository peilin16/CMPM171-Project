extends Level_controller
class_name Level1_controller


func _ready() -> void:
	_level = Level1.new();	
	GameManager.player_manager._spawn_player(self,Vector2(-200,0));
	super._ready();
