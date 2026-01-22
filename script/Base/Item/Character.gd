# scripts/character/Character.gd
extends Item
class_name Character


@export var max_hp: int = 10
@export var hp: int = 10

@export var isEnemy: bool = false;
@export var isDeath: bool = false;
@export var name: String;
@export var move_data:Move_data; #pattern recorder

func _init() -> void:
	move_data = Move_data.new();
