extends Control
class_name MahjongStatsPanel

@onready var damage_value: Label = $Background/Margin/Content/StatsGrid/DamageValue
@onready var attack_speed_value: Label = $Background/Margin/Content/StatsGrid/AttackSpeedValue
@onready var cooldown_value: Label = $Background/Margin/Content/StatsGrid/CooldownValue
@onready var move_speed_value: Label = $Background/Margin/Content/StatsGrid/MoveSpeedValue
@onready var bullet_speed_value: Label = $Background/Margin/Content/StatsGrid/BulletSpeedValue
@onready var defense_value: Label = $Background/Margin/Content/StatsGrid/DefenseValue
@onready var fire_mode_value: Label = $Background/Margin/Content/StatsGrid/FireModeValue
@onready var combo_value: Label = $Background/Margin/Content/ComboValue

var _pending_stats: Dictionary = {}

func _ready() -> void:
	update_upgrade_stats(_pending_stats)
	call_deferred("_attach_to_ui_layer")

func _attach_to_ui_layer() -> void:
	var player_controller := get_parent()
	if player_controller == null or not is_instance_valid(player_controller):
		return

	var ui_layer := player_controller.get_node_or_null("PlayerUICanvasLayer") as CanvasLayer
	if ui_layer == null or not is_instance_valid(ui_layer):
		ui_layer = CanvasLayer.new()
		ui_layer.name = "PlayerUICanvasLayer"
		ui_layer.layer = 1
		player_controller.add_child(ui_layer)

	reparent(ui_layer)
	anchors_preset = Control.PRESET_TOP_LEFT
	offset_left = 20.0
	offset_top = 56.0
	offset_right = 180.0
	offset_bottom = 130.0

func update_upgrade_stats(stats: Dictionary) -> void:
	if not is_node_ready() or damage_value == null:
		_pending_stats = stats.duplicate(true)
		return

	_pending_stats = stats.duplicate(true)
	damage_value.text = str(stats.get("damage", 0))
	attack_speed_value.text = _format_multiplier(float(stats.get("attack_speed_multiplier", 1.0)))
	cooldown_value.text = "%.2fs" % float(stats.get("shoot_cooldown", 0.0))
	move_speed_value.text = _format_multiplier(float(stats.get("move_speed_multiplier", 1.0)))
	bullet_speed_value.text = _format_multiplier(float(stats.get("bullet_speed_multiplier", 1.0)))
	defense_value.text = _format_percent(float(stats.get("damage_reduction", 0.0)))
	fire_mode_value.text = str(stats.get("fire_mode", "SINGLE"))

	var combos: Array = stats.get("active_combos", [])
	if combos.is_empty():
		combo_value.text = "None"
	else:
		combo_value.text = ", ".join(PackedStringArray(combos))

func _format_multiplier(value: float) -> String:
	return "x%.2f" % value

func _format_percent(value: float) -> String:
	return "%.0f%%" % (value * 100.0)
