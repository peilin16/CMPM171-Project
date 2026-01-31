# SFX_manager.gd
extends Node
class_name SFX_manager

@export var max_voices: int = 12
@export var default_polyphony: int = 3

@onready var templates_root: Node = get_node_or_null("Templates")
@onready var voices_root: Node = get_node_or_null("Voices")

var _parser := SFX_parser.new()

# template map: name -> AudioStreamPlayer2D (prototype)
var _templates: Dictionary = {}

# active voice tracking
class Voice:
	var player: AudioStreamPlayer2D
	var name: String
	var priority: int
	var started_time: float
	func _init(p, n, pri, t):
		player = p
		name = n
		priority = pri
		started_time = t

var _active_voices: Array[Voice] = []
var _active_count_by_name: Dictionary = {}     # name -> int
var _last_play_time_by_name: Dictionary = {}   # name -> float


func _ready() -> void:
	if voices_root == null:
		voices_root = Node.new()
		voices_root.name = "Voices"
		add_child(voices_root)

	if templates_root == null:
		# you can still register templates manually via register_template()
		pass
	else:
		_collect_templates()


func _collect_templates() -> void:
	_templates.clear()
	for c in templates_root.get_children():
		if c is AudioStreamPlayer2D:
			_templates[c.name] = c


func register_template(id: String, player: AudioStreamPlayer2D) -> void:
	_templates[id] = player


# --- Unified entry: cmd dict ---
# Example:
# sfx_manager.play_sound({
#   "sound":"sfx",
#   "name":"hit2",
#   "priority":8,
#   "pitch_scale":[0.9,1.1],
#   "volume_mul":[0.9,1.05],
#   "timbre_variant":[0,2],
#   "from_sec":0.0,
#   "to_sec":-1.0,
#   "polyphony":2,
#   "cooldown":0.03
# })
func play_sound(cmd: Dictionary) -> void:
	# only handle sfx here; bgm later
	if str(cmd.get("sound", "sfx")) != "sfx":
		return

	var req := _parser.build(cmd)
	if req.name == "":
		return

	_cleanup_finished_voices()

	# cooldown gate (per-name)
	var now := Time.get_ticks_msec() * 0.001
	var last_t: float = float(_last_play_time_by_name.get(req.name, -9999.0))
	if req.cooldown > 0.0 and (now - last_t) < req.cooldown:
		return

	# polyphony gate (per-name)
	var poly = (req.polyphony if req.polyphony > 0 else default_polyphony)
	var cur_count: int = int(_active_count_by_name.get(req.name, 0))
	if cur_count >= poly:
		# Policy: if new priority higher, replace the lowest-priority voice of same name
		if not _try_replace_same_name(req, now):
			return

	# global voice limit
	if _active_voices.size() >= max_voices:
		# if not important enough, drop it
		if not _try_preempt_lowest(req, now):
			return

	# spawn voice and play
	_spawn_voice(req, now)

	_last_play_time_by_name[req.name] = now


func _spawn_voice(req: SFX_request, now: float) -> void:
	var proto: AudioStreamPlayer2D = _templates.get(req.name, null)
	if proto == null:
		push_warning("SFX_manager: template not found: " + req.name)
		return

	var p := AudioStreamPlayer2D.new()
	voices_root.add_child(p)

	# copy important AudioStreamPlayer2D properties
	p.stream = proto.stream
	p.bus = req._resolved_bus
	p.volume_db = proto.volume_db
	p.pitch_scale = req.pitch_scale

	# 2D spatial defaults: copy if you rely on it
	p.position = proto.position
	p.max_distance = proto.max_distance
	p.attenuation = proto.attenuation
	p.panning_strength = proto.panning_strength

	# apply volume mul relative to template volume
	# volume_db += linear_to_db(mul)
	p.volume_db = proto.volume_db + linear_to_db(max(req.volume_mul, 0.0001))

	# connect cleanup
	if not p.finished.is_connected(_on_voice_finished):
		p.finished.connect(_on_voice_finished.bind(p))

	# play
	p.play(req.from_sec)

	# forced stop at to_sec
	if req._stop_after_sec > 0.0:
		var t := get_tree().create_timer(req._stop_after_sec)
		t.timeout.connect(_stop_voice_if_valid.bind(p))

	# bookkeeping
	_active_voices.append(Voice.new(p, req.name, req.priority, now))
	_active_count_by_name[req.name] = int(_active_count_by_name.get(req.name, 0)) + 1


func _stop_voice_if_valid(p: AudioStreamPlayer2D) -> void:
	if p == null: return
	if not is_instance_valid(p): return
	p.stop()
	# finished signal might not fire on stop; we cleanup here too
	_remove_voice(p)


func _on_voice_finished(p: AudioStreamPlayer2D) -> void:
	_remove_voice(p)


func _remove_voice(p: AudioStreamPlayer2D) -> void:
	if p == null or not is_instance_valid(p):
		return

	# find voice record
	for i in range(_active_voices.size()):
		var v := _active_voices[i]
		if v.player == p:
			# decrement count
			var nm := v.name
			var cur := int(_active_count_by_name.get(nm, 0))
			cur = max(cur - 1, 0)
			if cur == 0:
				_active_count_by_name.erase(nm)
			else:
				_active_count_by_name[nm] = cur

			_active_voices.remove_at(i)
			break

	p.queue_free()


func _cleanup_finished_voices() -> void:
	# defensive cleanup
	for v in _active_voices.duplicate():
		if v.player == null or not is_instance_valid(v.player):
			_active_voices.erase(v)


# ---- Preemption policies ----

# Replace a same-name voice if new priority higher than one existing
func _try_replace_same_name(req: SFX_request, now: float) -> bool:
	var lowest_idx := -1
	var lowest_pri := 999999

	for i in range(_active_voices.size()):
		var v := _active_voices[i]
		if v.name != req.name:
			continue
		if v.priority < lowest_pri:
			lowest_pri = v.priority
			lowest_idx = i

	if lowest_idx == -1:
		return false

	if req.priority > lowest_pri:
		var victim := _active_voices[lowest_idx].player
		_stop_voice_if_valid(victim)
		return true

	return false


# Kick lowest-priority voice if new is more important
func _try_preempt_lowest(req: SFX_request, now: float) -> bool:
	var lowest_idx := -1
	var lowest_pri := 999999
	var oldest_time := 999999.0

	for i in range(_active_voices.size()):
		var v := _active_voices[i]
		# pick lowest priority; tie-breaker: oldest
		if v.priority < lowest_pri or (v.priority == lowest_pri and v.started_time < oldest_time):
			lowest_pri = v.priority
			oldest_time = v.started_time
			lowest_idx = i

	if lowest_idx == -1:
		return false

	# Only preempt if new is strictly higher priority
	if req.priority > lowest_pri:
		var victim := _active_voices[lowest_idx].player
		_stop_voice_if_valid(victim)
		return true

	return false
