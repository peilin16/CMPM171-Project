extends Level_controller
class_name Level1_controller


func _ready() -> void:
	level = Level1.new();	
	pause_menu.visible =false;
	GameManager.player_manager._spawn_player(self,Vector2(-200,0));
	super._ready();
	
func _physics_process(delta: float) -> void:
	#print(GameManager.camera_manager.get_center())
	if Input.is_action_just_pressed("stop"):
		if not pause_menu.visible:
			pause_menu.visible = true;
		pause_menu.global_position = GameManager.camera_manager.get_center()
		get_tree().paused = true;
