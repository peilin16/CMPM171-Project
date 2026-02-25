extends Wave
class_name Shop_wave

func start(sub: Sub_director) -> void:
	GameManager.level_manager.current_level.display_shop();

func update(sub: Sub_director, delta: float) -> void:
	pass


func end(sub: Sub_director) -> void:
	pass
