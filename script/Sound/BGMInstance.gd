# BGM_instance.gd
extends Sound_instance
class_name BGM_instance

@export var loop_enabled: bool = true
@export var loop_start_sec: float = 0.0   # intro ends, loop begins
@export var loop_end_sec: float = 0.0     # loop ends, outro begins
@export var stop_jump_to_outro: bool = false  # stop loop时是否立刻跳到loop_end

var _want_stop_loop: bool = false

func _ready() -> void:
	super._ready()
	bus = "BGM"

func play_bgm(from_sec: float = -1.0, end_sec: float = -1.0) -> void:
	_want_stop_loop = false
	loop_enabled = true
	play_sound(from_sec, end_sec);

func stop_loop_and_finish() -> void:
	# 关闭循环，让它继续播到结尾（outro）
	_want_stop_loop = true
	loop_enabled = false
	if stop_jump_to_outro and loop_end_sec > 0.0:
		seek(loop_end_sec)

func stop_bgm_immediately() -> void:
	stop_sound()

func _process(_delta: float) -> void:
	if not playing:
		return

	# 没设置 loop_end 就不做分段循环
	if loop_enabled and loop_end_sec > 0.0:
		var t := get_playback_position()
		if t >= loop_end_sec:
			# 回到 loop_start
			seek(max(loop_start_sec, 0.0))
