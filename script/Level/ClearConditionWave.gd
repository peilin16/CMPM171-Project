# Wave.gd
extends Wave
class_name Clear_condition_wave


	
func is_done(sub: Sub_director) -> bool:
	if GameManager.enemy_manager == null:
		return true
	return GameManager.enemy_manager.get_active_enemy_count() == 0;
