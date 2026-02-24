extends Node
class_name Hurt_box

var can_hurt:bool = false;
@onready var sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
var tween: Tween;
@export var player_hp:float = 100; 

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
