# BGM_manager.gd
extends Node
class_name BGM_manager

var _map: Dictionary = {} # id -> BGM_instance
var _current: BGM_instance

func _ready() -> void:
	_map.clear()
	for c in get_children():
		if c is BGM_instance:
			var b := c as BGM_instance
			if b.sound_id != "":
				_map[b.sound_id] = b

func play_bgm(id: String) -> void:
	var b: BGM_instance = _map.get(id)
	if b == null: return

	if _current != null and _current != b:
		_current.stop_bgm_immediately()

	_current = b
	_current.play_bgm()

func stop_loop_and_finish() -> void:
	if _current:
		_current.stop_loop_and_finish()

func stop_bgm() -> void:
	if _current:
		_current.stop_bgm_immediately()
	_current = null
