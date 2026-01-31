# SFX_request.gd
extends Resource
class_name SFX_request

# Required
@export var name: String = ""         # sound id, e.g. "hit2"

# Mixing / routing
@export var priority: int = 0         # bigger = more important
@export var bus: String = "SFX"       # default SFX bus
@export var timbre_bus: String = ""   # optional override: "SFX_VAR1"

# Playback
@export var pitch_scale: float = 1.0
@export var volume_mul: float = 1.0   # 1.0 = unchanged

@export var from_sec: float = 0.0     # start offset (seconds)
@export var to_sec: float = -1.0      # end offset (seconds), -1 = play full

# Limiting
@export var polyphony: int = 3        # same-name max voices
@export var cooldown: float = 0.0     # same-name minimum interval seconds

# Runtime (filled by parser/manager)
var _resolved_bus: String = "SFX"
var _stop_after_sec: float = -1.0     # computed duration to stop, -1=no forced stop

func _init() -> void:
	priority = 0
	pitch_scale = 1.0
	volume_mul = 1.0
	from_sec = 0.0
	to_sec = -1.0
	polyphony = 3
	cooldown = 0.0
