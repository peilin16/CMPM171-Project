extends Wave
class_name Shop_wave

const SHOP_OPEN_DELAY := 1.0

var _waiting_for_close: bool = false
var _delay_timer: float = 0.0
var _shop_opened: bool = false

func start(_sub: Sub_director) -> void:
	_waiting_for_close = true
	_delay_timer = SHOP_OPEN_DELAY
	_shop_opened = false

func update(_sub: Sub_director, delta: float) -> void:
	if _shop_opened:
		return
	if GameManager.level_manager == null:
		_shop_opened = true
		return

	_delay_timer -= delta
	if _delay_timer > 0.0:
		return

	var level: Level_controller = GameManager.level_manager.current_level
	if level != null:
		level.display_shop()
	_shop_opened = true



func is_done(_sub: Sub_director) -> bool:
	if not _waiting_for_close:
		return true
	if not _shop_opened:
		return false
	if GameManager.level_manager == null:
		return true
	var level: Level_controller = GameManager.level_manager.current_level
	if level == null or level.shop_menu == null:
		return true
	return not level.shop_menu.visible

func end(_sub: Sub_director) -> void:
	_waiting_for_close = false
	_shop_opened = false
	_delay_timer = 0.0
