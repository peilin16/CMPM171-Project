extends Node
class_name AccessibilityManager

const VALID_MODES := ["off", "protanopia", "deuteranopia", "tritanopia"]

var _colorblind_mode: String = "off"

func set_colorblind_mode(mode: String) -> void:
	if mode not in VALID_MODES:
		printerr("AccessibilityManager: invalid mode '%s', falling back to 'off'" % mode)
		mode = "off"
	_colorblind_mode = mode
	GameManager.accessibility_mode_changed.emit(mode)

func get_colorblind_mode() -> String:
	return _colorblind_mode
