extends Area2D
class_name Hurt_box

var can_hurt:bool = false;
@onready var sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
var tween: Tween;
@export var player_hp:float = 100; 
var controller:Player_controller;
func open()->void:
	can_hurt = true;

func close()->void:
	can_hurt = false;

func _ready():
	# 确保 sprite 存在
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
