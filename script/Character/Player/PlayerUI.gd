extends Control
class_name Player_UI
@onready var health_bar:ProgressBar = $HealthBar
@onready var shoot_timer:AnimatedSprite2D = $ShootBar

var player_controller:Player_controller;
var hurt_box:Hurt_box;
var ui_layer: CanvasLayer

func _ready() -> void:
	player_controller = get_parent();
	call_deferred("_attach_to_ui_layer")
	await  ToolBar.globalDelayCall.delay(1);
	

func _attach_to_ui_layer() -> void:
	if player_controller == null or not is_instance_valid(player_controller):
		return
	if ui_layer == null or not is_instance_valid(ui_layer):
		ui_layer = CanvasLayer.new()
		ui_layer.name = "PlayerUICanvasLayer"
		ui_layer.layer = 1
		player_controller.add_child(ui_layer)
	reparent(ui_layer)
	anchors_preset = Control.PRESET_TOP_LEFT
	offset_left = 20.0
	offset_top = 20.0
	offset_right = 184.0
	offset_bottom = 134.0
	

func _physics_process(delta: float) -> void:
	if not hurt_box:
		hurt_box = player_controller.hurtbox;
	health_bar.value = hurt_box.player_hp;
	
