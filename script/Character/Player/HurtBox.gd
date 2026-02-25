extends Area2D
class_name Hurt_box

var can_hurt:bool = false;
@onready var sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
var tween: Tween;
@export var player_hp:float = 100; 
var controller:Player_controller;
var timer:float = 0;
func open()->void:
	can_hurt = true;

func close()->void:
	can_hurt = false;

func _ready():
	
	player_hp = 100;
	if sprite:
		sprite.modulate = Color(1, 1, 1, 0)  
		sprite.visible = false  # hide
	can_hurt = true;
	controller = get_parent();

func _on_area_entered(area: Area2D) -> void:
	if area is Widget_controller:
		controller.logic.add_score(5);
		return;
	 # Replace with function body.

func hurt(num:float)->void:
	player_hp -= num
func _physics_process(delta: float) -> void:
	if not can_hurt:
		timer += delta;
	else:
		return;
	if timer >=0.6:
		can_hurt = true;
		timer = 0;

func _on_body_entered(body: Node2D) -> void:
	if body is not Enemy_controller:
		return;
	if not can_hurt:
		return;
	can_hurt = false;
	hurt(3);
