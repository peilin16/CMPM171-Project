extends Control
class_name Player_UI
@onready var health_bar:ProgressBar = $HealthBar
@onready var shoot_timer:AnimatedSprite2D = $ShootBar

var player_controller:Player_controller;
var hurt_box:Hurt_box;

func _ready() -> void:
	player_controller = get_parent();
	await  ToolBar.globalDelayCall.delay(1);
	

func _physics_process(delta: float) -> void:
	if not hurt_box:
		hurt_box = player_controller.hurtbox;
	health_bar.value = hurt_box.player_hp;
	
