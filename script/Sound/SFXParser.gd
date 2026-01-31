# SFX_parser.gd
extends Resource
class_name SFX_parser

# If you have your own repeatable RNG system, you can inject it here.
# For now: use Godot RNG with optional "seed" / "seed_index" in cmd.
var _rng := RandomNumberGenerator.new()

# Public: build request from cmd dict
func build(cmd: Dictionary) -> SFX_request:
	var req := SFX_request.new()

	# --- Required ---
	req.name = str(cmd.get("name", ""))

	# --- Priority / bus ---
	req.priority = int(cmd.get("priority", 0))
	req.bus = str(cmd.get("bus", "SFX"))

	# --- Pitch / volume (float or [min,max]) ---
	req.pitch_scale = _read_float_or_range(cmd.get("pitch_scale", 1.0), 1.0, 0.01, 4.0)
	req.volume_mul  = _read_float_or_range(cmd.get("volume_mul", 1.0), 1.0, 0.0, 4.0)

	# --- Segment play ---
	req.from_sec = float(cmd.get("from_sec", 0.0))
	req.to_sec   = float(cmd.get("to_sec", -1.0))

	# --- Limits ---
	req.polyphony = int(cmd.get("polyphony", 3))
	req.cooldown  = float(cmd.get("cooldown", 0.0))

	# --- Timbre routing ---
	# cmd can provide:
	# timbre_bus: "SFX_VAR1"
	# OR timbre_variant: 1 or [0,2]
	var tb :String= cmd.get("timbre_bus", "")
	if typeof(tb) == TYPE_STRING and tb != "":
		req.timbre_bus = tb
	else:
		var tv = cmd.get("timbre_variant", null)
		if tv != null:
			var variant := _read_int_or_range(tv, 0, 0, 32)
			req.timbre_bus = "SFX_VAR" + str(variant)

	# --- Optional seed control (repeatable) ---
	# If cmd provides seed, we set RNG for this build (repeatable).
	# You can replace this with your ToolBar.repeatableRandomGenerator later.
	if cmd.has("seed"):
		_rng.seed = int(cmd["seed"])
	elif cmd.has("seed_index"):
		# If you manage 200 seeds somewhere, map seed_index -> seed in your own system.
		# Here we just make it deterministic:
		var idx := int(cmd["seed_index"])
		_rng.seed = 10007 + idx * 97

	# Resolve final bus
	req._resolved_bus = (req.timbre_bus if req.timbre_bus != "" else req.bus)

	# Compute stop duration if to_sec is set
	if req.to_sec >= 0.0 and req.to_sec > req.from_sec:
		# If pitch_scale > 1.0, playback finishes sooner.
		var raw_len := req.to_sec - req.from_sec
		req._stop_after_sec = raw_len / max(req.pitch_scale, 0.01)
	else:
		req._stop_after_sec = -1.0

	return req


# ---------- helpers ----------

func _read_float_or_range(v, default_value: float, minv: float, maxv: float) -> float:
	if typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT:
		return clamp(float(v), minv, maxv)
	if typeof(v) == TYPE_ARRAY and v.size() >= 2:
		var a := float(v[0])
		var b := float(v[1])
		var lo :float= min(a, b)
		var hi :float= max(a, b)
		lo = clamp(lo, minv, maxv)
		hi = clamp(hi, minv, maxv)
		return _rng.randf_range(lo, hi)
	return default_value


func _read_int_or_range(v, default_value: int, minv: int, maxv: int) -> int:
	if typeof(v) == TYPE_INT:
		return clamp(int(v), minv, maxv)
	if typeof(v) == TYPE_FLOAT:
		return clamp(int(round(v)), minv, maxv)
	if typeof(v) == TYPE_ARRAY and v.size() >= 2:
		var a := int(v[0])
		var b := int(v[1])
		var lo :float= min(a, b)
		var hi :float= max(a, b)
		lo = clamp(lo, minv, maxv)
		hi = clamp(hi, minv, maxv)
		return _rng.randi_range(lo, hi)
	return default_value
