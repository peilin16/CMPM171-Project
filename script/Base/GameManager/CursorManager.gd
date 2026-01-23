extends Node
class_name Cursor_manager

# 事件名常量：避免写错字符串
const EVT_LMB_DOWN := "shoot"
const EVT_LMB_UP := "SwitchWeapon"
const EVT_WHEEL_DOWN := "wheel_down"

# 每种事件 -> 一个字典( id:String -> cb:Callable )
# 这样同一种事件可以注册多个回调
var _listeners: Dictionary = {
	EVT_LMB_DOWN: {},
	EVT_LMB_UP: {},
	EVT_WHEEL_DOWN: {},
}

# 是否启用（可以随时开关）
var enabled: bool = true


# -------------------------
# 鼠标位置 API
# -------------------------
func get_mouse_viewport_pos() -> Vector2:
	return get_viewport().get_mouse_position()

func get_mouse_world_pos() -> Vector2:
	# 需要这个节点在 2D 世界里（有 CanvasItem/Node2D 环境）
	# 如果 Cursor_manager 放在 Autoload 单例里也没问题，通常依旧能拿到正确值
	return get_viewport().get_canvas_transform().affine_inverse() * get_mouse_viewport_pos()
	# 也可以用 get_tree().current_scene.get_viewport(). ...（看你项目结构）


# -------------------------
# 事件注册/注销
# -------------------------
func on(event_name: String, id: String, cb: Callable) -> void:
	if not _listeners.has(event_name):
		_listeners[event_name] = {}
	_listeners[event_name][id] = cb

func off(event_name: String, id: String) -> void:
	if _listeners.has(event_name):
		_listeners[event_name].erase(id)

func clear(event_name: String) -> void:
	if _listeners.has(event_name):
		_listeners[event_name].clear()

func emit_event(event_name: String, payload := {}) -> void:
	if not enabled:
		return
	if not _listeners.has(event_name):
		return

	var ids :Array= _listeners[event_name].keys()
	for id in ids:
		var cb: Callable = _listeners[event_name].get(id)
		if cb == null:
			continue
		if cb.is_valid():
			# 回调统一收一个 payload 字典，方便扩展
			cb.call(payload)
		else:
			# 目标销毁了就自动移除
			_listeners[event_name].erase(id)


# -------------------------
# 输入捕获：建议用 _unhandled_input
# - 这样 UI（按钮、面板）先吃输入
# - UI 没处理的再到这里
# -------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return

	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton

		# 左键按下 / 释放
		if e.button_index == MOUSE_BUTTON_LEFT:
			var payload := {
				"viewport_pos": e.position,
				"world_pos": get_mouse_world_pos(),
				"pressed": e.pressed,
				"double_click": e.double_click,
			}
			if e.pressed:
				emit_event(EVT_LMB_DOWN, payload)
			else:
				emit_event(EVT_LMB_UP, payload)

		# 滚轮下移（注意：滚轮是“按下事件”，一般只看 pressed == true）
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			var payload2 := {
				"viewport_pos": e.position,
				"world_pos": get_mouse_world_pos(),
			}
			emit_event(EVT_WHEEL_DOWN, payload2)
