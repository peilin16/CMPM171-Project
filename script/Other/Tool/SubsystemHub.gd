# SubsystemHub.gd
extends Node2D
class_name Sub_action_hub

@onready var shoot_runner: Shoot_runner = get_node_or_null("ShootRunner") as Shoot_runner
@onready var move_runner: Move_runner = get_node_or_null("MoveRunner") as Move_runner
@onready var rotate_runner:Rotate_runner = get_node_or_null("RotateRunner") as Rotate_runner
#@export var anim_runner: AnimRunner

func get_runner_for(belong: System.Belong) -> Runner:
	match belong:
		System.Belong.SHOOT:
			return shoot_runner
		System.Belong.MOVE:
			return move_runner
		System.Belong.ROTATE:
			return rotate_runner
	return null
