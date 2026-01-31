# SFX_instance.gd
extends Sound_instance
class_name SFX_instance

@export var priority: int = 0
@export var cooldown: float = 0.0

var _cd: float = 0.0

func _ready() -> void:
	super._ready()
	bus = "SFX"

func can_play() -> bool:
	return _cd <= 0.0

func play_by_request(req: SFX_request) -> void:
	if not can_play():
		return
	_cd = cooldown

	# apply pitch & volume
	var pitch := randf_range(req.pitch_min, req.pitch_max)
	pitch_scale = pitch

	var vol_mul := randf_range(req.vol_mul_min, req.vol_mul_max)
	set_volume_mul(vol_mul)

	play_sound(req.from_sec, req.to_sec)

func _process(delta: float) -> void:
	super._process(delta)
	if _cd > 0.0:
		_cd -= delta
