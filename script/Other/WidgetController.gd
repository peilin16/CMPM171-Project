extends Area2D
class_name Widget_controller

var pool_name:String = "PowerPointPool"
var is_close_to_player:bool = false;
var speed:float = 300;



func deactivate()->void:
	PoolManager.widget_pool_manager._deactivate_widget(pool_name,self);
	
func _physics_process(delta: float) -> void:
	if not is_close_to_player:
		return

	var dir: Vector2 = (GameManager.player_manager.get_player_position() - global_position).normalized()

	global_position += dir * speed * delta

	if global_position.distance_to(GameManager.player_manager.get_player_position()) < 5.0:
		deactivate()
	

func _on_area_entered(area: Area2D) -> void:
	is_close_to_player = true; # Replace with function body.
