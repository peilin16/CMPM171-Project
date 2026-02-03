# BGM_request.gd
extends Resource
class_name BGM_request

# command: "start" | "stop" | "interrupt" | "transfer"
@export var command: String = "start"
@export var name: String = ""              # bgm id / node name / key

# playback
@export var volume_mul: float = 1.0        # 1.0 = base volume
@export var pitch_scale: float = 1.0       # pitch & speed feel (AudioStreamPlayer2D)
@export var from_sec: float = 0.0          # start position
@export var to_sec: float = -1.0           # if >= 0 stop at time

# fade
@export var fade_in: float = 0.0
@export var fade_out: float = 0.0

# loop segment (intro -> loop -> outro)
@export var use_loop_segment: bool = false
@export var loop_start_sec: float = 0.0
@export var loop_end_sec: float = 0.0      # must be > loop_start_sec

# when stopping, do we "finish" (play outro) or just fade out?
@export var stop_loop_and_finish: bool = false

# transfer (crossfade)
@export var transfer_fade_out: float = 0.5
@export var transfer_fade_in: float = 0.5
