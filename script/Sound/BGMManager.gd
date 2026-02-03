# BGM_manager.gd
extends Node
class_name BGM_manager

@export var bgm_root: NodePath
var _root: Node = null

var _current: BGM_instance
var _next: BGM_instance

# remember last stop position per track
var _resume_pos: Dictionary = {}  # name -> float
var parser:BGM_parser = BGM_parser.new();
func _ready() -> void:
	_root = get_node_or_null(bgm_root)
	if _root == null:
		_root = self

	# you can either:
	# A) place two BGM_instance nodes under this manager in scene: "BGM_A", "BGM_B"
	# B) or create them at runtime:
	_current = _ensure_player("BGM_A")
	_next = _ensure_player("BGM_B")

func _ensure_player(n: String) -> BGM_instance:
	var p := _root.get_node_or_null(n) as BGM_instance
	if p == null:
		p = BGM_instance.new()
		p.name = n
		_root.add_child(p)
	return p

func _get_bgm_node(name: String) -> BGM_instance:
	# your project likely stores BGM nodes in scene or a pool.
	# simplest: find by name under manager:
	var node := _root.get_node_or_null(name) as BGM_instance
	return node

func execute(cmd:Dictionary) -> void:
	var req:BGM_request = parser.parse(cmd)
	
	match req.command:
		"start":
			start(req)
		"stop":
			stop(req)
		"interrupt":
			interrupt()
		"transfer":
			transfer(req)
		"stop_loop_and_finish":
			stop_loop_and_finish(req)
		_:
			push_warning("BGM_manager: unknown command: " + req.command)

func start(req: BGM_request) -> void:
	if req.name == "":
		return

	# if current is already playing the same track -> resume or restart
	if _current.sound_id == req.name and _current.stream != null:
		var resume = _resume_pos.get(req.name, 0.0)
		var pos = (resume if resume > 0.0 else req.from_sec)
		_current.play_bgm(req)
		_current.seek(pos)
		return

	# otherwise load/assign stream from a named BGM_instance node if you keep streams there
	var src := _get_bgm_node(req.name)
	if src == null:
		push_warning("BGM_manager: BGM node not found: " + req.name)
		return

	# copy stream into current player
	_current.stream = src.stream
	_current.sound_id = req.name
	_current.play_bgm(req)

func stop(req: BGM_request) -> void:
	if _current.playing:
		_resume_pos[_current.sound_id] = _current.get_playback_position()
		_current.stop_bgm(req)

func interrupt() -> void:
	if _current.playing:
		_resume_pos[_current.sound_id] = _current.get_playback_position()
	_current.interrupt_bgm()
	_next.interrupt_bgm()

func stop_loop_and_finish(req: BGM_request) -> void:
	# let current exit loop; keep playing tail
	if _current.playing:
		_current.stop_loop_and_finish(req)

func transfer(req: BGM_request) -> void:
	# crossfade to another bgm
	if req.name == "":
		return

	var src := _get_bgm_node(req.name)
	if src == null:
		push_warning("BGM_manager: BGM node not found: " + req.name)
		return

	# setup next
	_next.interrupt_bgm()
	_next.stream = src.stream
	_next.sound_id = req.name

	# next fade-in config
	var next_req := req.duplicate();
	next_req.fade_in = req.transfer_fade_in
	next_req.fade_out = 0.0
	_next.play_bgm(next_req)

	# current fade-out
	if _current.playing:
		var stop_req := BGM_request.new()
		stop_req.fade_out = req.transfer_fade_out
		_current.stop_bgm(stop_req)

	# swap roles after fade time (use timer)
	var swap_delay :float= max(req.transfer_fade_out, req.transfer_fade_in)
	if swap_delay <= 0.0:
		_swap_players()
	else:
		var t := get_tree().create_timer(swap_delay)
		t.timeout.connect(_swap_players)

func _swap_players() -> void:
	var tmp := _current
	_current = _next
	_next = tmp
