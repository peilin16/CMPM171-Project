extends Sprite2D
class_name Bullet_texture_controller

@export var skins: Array[Texture2D]   # Texture

@export var current_skin_index :int= 0
#var parent_controller: bullet_controller;


func _apply_skin() -> void:
	if current_skin_index >= 0 and current_skin_index < skins.size():
		texture = skins[current_skin_index]

func set_skin(index: int) -> void:
	current_skin_index = index
	_apply_skin()
