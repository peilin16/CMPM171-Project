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
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = "BGM"
	# BGM should be non-spatial (avoid volume dropping when listener/camera moves away)
	attenuation = 0.0
	max_distance = 1000000.0
	panning_strength = 0.0

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

	var t: float = get_playback_position()

	# loop segment
	if loop_enabled:
		var effective_end: float = loop_end_sec
		if stream != null:
			var stream_len: float = max(float(stream.get_length()), 0.0)
			if stream_len > 0.0:
				if effective_end <= loop_start_sec or effective_end > stream_len:
					effective_end = max(stream_len - 0.02, loop_start_sec + 0.01)
		if effective_end > loop_start_sec and t >= effective_end:
			seek(loop_start_sec)

	# stop at time (cut segment)
	if _stop_at_sec >= 0.0 and t >= _stop_at_sec:
		_stop_at_sec = -1.0
		# in finish mode, allow fade_out (if set) then stop
		stop_sound()
