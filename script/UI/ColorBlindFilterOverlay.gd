extends CanvasLayer
class_name ColorBlindFilterOverlay

## Full-screen color-blind filter overlay.
## Add as child of any scene root; reads mode from GameManager on ready
## and listens for runtime changes via GameManager.accessibility_mode_changed.

var _color_rect: ColorRect
var _shader_material: ShaderMaterial

const MODE_MAP := {
	"off": 0,
	"protanopia": 1,
	"deuteranopia": 2,
	"tritanopia": 3,
}

func _ready() -> void:
	layer = 100
	_setup_overlay()
	# Apply the current mode immediately
	apply_mode(GameManager.get_colorblind_mode())
	# Listen for future changes
	GameManager.accessibility_mode_changed.connect(apply_mode)

func _setup_overlay() -> void:
	_color_rect = ColorRect.new()
	_color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.color = Color(1, 1, 1, 1)

	var shader = load("res://scenes/UI/ColorBlindFilter.gdshader") as Shader
	if shader == null:
		printerr("ColorBlindFilterOverlay: shader failed to load!")
		return
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = shader

	_color_rect.material = _shader_material
	add_child(_color_rect)
	print("ColorBlindFilterOverlay: overlay ready, rect size = ", _color_rect.size)

func apply_mode(mode_name: String) -> void:
	var mode_id: int = MODE_MAP.get(mode_name, 0)
	if _shader_material:
		_shader_material.set_shader_parameter("mode", float(mode_id))
	print("ColorBlindFilterOverlay: mode changed to '%s' (id=%d)" % [mode_name, mode_id])
