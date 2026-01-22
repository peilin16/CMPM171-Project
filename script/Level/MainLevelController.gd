extends Level_controller
class_name Main_level_controller


func _ready() -> void:
	_level = Main_level.new();	
	GameManager.player_manager._spawn_player(self,Vector2(-200,0));
	super._ready();
