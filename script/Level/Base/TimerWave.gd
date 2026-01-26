# Timer_wave.gd
extends Wave
class_name Timer_wave

@export var duration: float = 3.0    #How long

var _elapsed: float = 0.0
var _finished: bool = false

func start(sub: Sub_director) -> void:
	_elapsed = 0.0
	_finished = false
	# 如果需要，可以通知背景导演调整速度：
	# sub.background_director.scroll_speed = 50.0


func update(sub: Sub_director, delta: float) -> void:
	_elapsed += delta
	
func is_done(sub: Sub_director) ->bool:
	if _finished:
		return true
	if _elapsed >= duration:
		_finished = true
	return _finished


func end(sub: Sub_director) -> void:
	# 计时结束后的收尾动作（可选）
	# 比如减慢背景速度 / 淡出音乐等
	pass
func config(_duration:float)->void:
	duration = _duration;
