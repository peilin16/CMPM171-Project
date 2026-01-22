extends Node
class_name Global_delay_call

var _active_timers: Dictionary = {}  # 


func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

# delay call tsec
func delay_call(delay_seconds: float, callback: Callable, params: Array = [])->int:
	return _create_timer(delay_seconds, callback, params)
# delay sec
# await GlobalDelay.delay(0.5)
func delay(delay_seconds: float) -> Signal:
	var timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.start()
	
	# time out
	return timer.timeout

# create timer
func _create_timer(delay_seconds: float, callback: Callable, params: Array) ->int:
	var timer_item = Timer_item.new()
	var id = ToolBar.gameIDGenerator.generate_id();
	
	timer_item.id = id;
	timer_item.callback = callback
	timer_item.params = params
	
	var timer = Timer.new()
	add_child(timer)
	timer_item.timer = timer
	_active_timers[timer_item.id] = timer_item
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.timeout.connect(_on_delay_call_timeout.bind(callback, params, timer))
	timer.start()
	return timer_item.id
	
#call back
func _on_delay_call_timeout(timer_id: int):
	if not _active_timers.has(timer_id):
		return
	
	var timer_item: Timer_item = _active_timers[timer_id]
	
	# call back
	if timer_item.params.is_empty():
		timer_item.callback.call()
	else:
		timer_item.callback.callv(timer_item.params)
	
	_cleanup_timer(timer_id)
	
# clean
func _cleanup_timer(timer_id: int):
	if not _active_timers.has(timer_id):
		return
	
	var timer_item: Timer_item = _active_timers[timer_id]
	
	# 断开连接并停止计时器
	if timer_item.timer and is_instance_valid(timer_item.timer):
		timer_item.timer.stop()
		timer_item.timer.queue_free()
	
	# erase
	_active_timers.erase(timer_id)

# 立即跳过指定的延迟调用（执行回调并清理）
func skip(timer_id: int) -> bool:
	if not _active_timers.has(timer_id):
		return false
	
	var timer_item: Timer_item = _active_timers[timer_id]
	
	# 立即执行回调
	if timer_item.params.is_empty():
		timer_item.callback.call()
	else:
		timer_item.callback.callv(timer_item.params)
	
	# 清理
	_cleanup_timer(timer_id)
	
	return true

# 取消指定的延迟调用（不执行回调）
func cancel(timer_id: int) -> bool:
	if not _active_timers.has(timer_id):
		return false
	
	# 直接清理，不执行回调
	_cleanup_timer(timer_id)
	
	return true

# 取消所有活跃的延迟调用
func cancel_all() -> void:
	for timer_id in _active_timers.keys().duplicate():
		cancel(timer_id)

# 跳过所有活跃的延迟调用
func skip_all() -> void:
	for timer_id in _active_timers.keys().duplicate():
		skip(timer_id)

# 获取活跃的延迟调用数量
func get_active_count() -> int:
	return _active_timers.size()
