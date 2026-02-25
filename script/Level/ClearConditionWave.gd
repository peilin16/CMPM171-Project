# Wave.gd
extends Wave
class_name Clear_condition_wave


	
func is_done(sub: Sub_director) -> bool:
	return GameManager.enemy_manager._active_enemies.size() == 0;
