# BGM_instance.gd
extends Sound_instance
class_name BGM_instance

@export var loop_enabled: bool = false
@export var loop_start_sec: float = 0.0
@export var loop_end_sec: float = 0.0


# if true: when asked to "stop loop and finish", we disable loop and let it play to end/_stop_at_sec
var _finish_mode: bool = false

func _ready() -> void:
	super._ready()
	bus = "BGM"

func apply_request(req: BGM_request) -> void:
	# base params
	set_volume_mul(req.volume_mul)
	pitch_scale = req.pitch_scale

	# segment / stop
	_stop_at_sec = req.to_sec
	_finish_mode = false

	# loop segment
	loop_enabled = req.use_loop_segment
	loop_start_sec = req.loop_start_sec
	loop_end_sec = req.loop_end_sec

	# fades
	fade_in = req.fade_in
	fade_out = req.fade_out

func play_bgm(req: BGM_request) -> void:
	apply_request(req)
	play_sound(req.from_sec)

func stop_bgm(req: BGM_request) -> void:
	# normal stop with fade_out
	_stop_at_sec = -1.0
	_finish_mode = false
	fade_out = req.fade_out
	stop_sound()

func interrupt_bgm() -> void:
	# immediate stop (no fade)
	_stop_at_sec = -1.0
	_finish_mode = false
	stop()

func stop_loop_and_finish(req: BGM_request) -> void:
	# disable loop now; let it naturally go (optionally stop_at_sec)
	_finish_mode = true
	loop_enabled = false
	# if you want fade-out at end instead of hard stop:
	fade_out = req.fade_out

func _physics_process(delta: float) -> void:
	if not playing:
		return

	var t := get_playback_position()

	# loop segment
	if loop_enabled and loop_end_sec > loop_start_sec:
		if t >= loop_end_sec:
			seek(loop_start_sec)

	# stop at time (cut segment)
	if _stop_at_sec >= 0.0 and t >= _stop_at_sec:
		_stop_at_sec = -1.0
		# in finish mode, allow fade_out (if set) then stop
		stop_sound()
