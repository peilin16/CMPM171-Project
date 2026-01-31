# Sound_instance.gd
extends AudioStreamPlayer2D
class_name Sound_instance

@export var sound_id: String = ""
@export var base_volume_db: float = 0.0
@export var fade_in: float = 0.0
@export var fade_out: float = 0.0
#default start and end
@export var default_start:float = 0.0;
@export var default_to:float =  -1;


var _tween: Tween
var _stop_at_sec: float = -1.0  # >=0 means stop when playback reaches it

func _ready() -> void:
	volume_db = base_volume_db
	if sound_id == "":
		sound_id = name

func play_sound(from_sec: float = 0.0, to_sec: float = -1.0) -> void:
	if to_sec == -1 and default_to != -1:
		_stop_at_sec = default_to;
	else:
		_stop_at_sec = to_sec
	_apply_fade_in();
	if from_sec == 0 and default_start != 0.0:
		play(default_start);
	else:
		play(from_sec);
func stop_sound() -> void:
	_stop_at_sec = -1.0
	if fade_out > 0.0:
		_apply_fade_out_and_stop()
	else:
		stop()

func set_volume_mul(mul: float) -> void:
	# mul=1 -> base, mul=0.5 -> quieter
	volume_db = base_volume_db + linear_to_db(max(mul, 0.0001))

func _process(_delta: float) -> void:
	if _stop_at_sec >= 0.0 and playing:
		if get_playback_position() >= _stop_at_sec:
			stop_sound()

func _apply_fade_in() -> void:
	if fade_in <= 0.0: return
	if _tween and _tween.is_running(): _tween.kill()
	var target := base_volume_db
	volume_db = -60.0
	_tween = create_tween()
	_tween.tween_property(self, "volume_db", target, fade_in)

func _apply_fade_out_and_stop() -> void:
	if _tween and _tween.is_running(): _tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "volume_db", -60.0, fade_out)
	_tween.tween_callback(Callable(self, "stop"))
