extends Wave
class_name Shop_wave

var _waiting_for_close: bool = false

func start(_sub: Sub_director) -> void:
	_waiting_for_close = true
	GameManager.level_manager.current_level.display_shop();

func update(_sub: Sub_director, _delta: float) -> void:
	pass



func is_done(_sub: Sub_director) -> bool:
	if not _waiting_for_close:
		return true
	if GameManager.level_manager == null:
		return true
	var level: Level_controller = GameManager.level_manager.current_level
	if level == null or level.shop_menu == null:
		return true
	return not level.shop_menu.visible

func end(_sub: Sub_director) -> void:
	_waiting_for_close = false
	pass
