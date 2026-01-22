extends Resource
class_name Timer_item

var id: int = 0
var timer: Timer = null
var callback: Callable = Callable()
var params: Array = []
var created_time: int = 0

func _init():
	created_time = Time.get_ticks_msec()
	
func destory():
	ToolBar.gameIDGenerator.recycle_id(id);
