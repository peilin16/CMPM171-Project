extends Node
class_name Hurt_box

var can_hurt:bool = false;
@onready var sprite:Sprite2D = $Sprite
var tween: Tween


func _ready():
	# 确保 sprite 存在
	if sprite:
		sprite.modulate = Color(1, 1, 1, 0)  
		sprite.visible = false  # hide
	can_hurt = true;
