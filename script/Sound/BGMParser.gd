# BGM_parser.gd
extends Resource
class_name BGM_parser

# helper: value could be float or [min,max]
func _parse_float(v, default_value: float) -> float:
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		return float(v)
	if typeof(v) == TYPE_ARRAY and v.size() >= 2:
		return randf_range(float(v[0]), float(v[1]))
	return default_value

func parse(cmd: Dictionary) -> BGM_request:
	var req := BGM_request.new()

	req.command = str(cmd.get("command", "start"))
	req.name = str(cmd.get("name", ""))

	req.from_sec = float(cmd.get("from_sec", 0.0))
	req.to_sec = float(cmd.get("to_sec", -1.0))

	req.fade_in = float(cmd.get("fade_in", 0.0))
	req.fade_out = float(cmd.get("fade_out", 0.0))

	req.volume_mul = _parse_float(cmd.get("volume_mul", 1.0), 1.0)
	req.pitch_scale = _parse_float(cmd.get("pitch_scale", 1.0), 1.0)

	# loop segment
	req.use_loop_segment = bool(cmd.get("use_loop_segment", false))
	req.loop_start_sec = float(cmd.get("loop_start_sec", 0.0))
	req.loop_end_sec = float(cmd.get("loop_end_sec", 0.0))
	req.stop_loop_and_finish = bool(cmd.get("stop_loop_and_finish", false))

	# transfer
	req.transfer_fade_out = float(cmd.get("transfer_fade_out", 0.5))
	req.transfer_fade_in = float(cmd.get("transfer_fade_in", 0.5))

	return req
