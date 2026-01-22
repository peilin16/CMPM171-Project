# SubsystemHub.gd
extends Node2D
class_name Sub_action_hub

@onready var shoot_runner: Shoot_runner = $ShootRunner
@onready var move_runner: Move_runner = $MoveRunner
@onready var rotate_runner:Rotate_runner = $RotateRunner
#@export var anim_runner: AnimRunner

func get_runner_for(belong: System.Belong) -> Runner:
	match belong:
		System.Belong.SHOOT:
			return shoot_runner
		System.Belong.MOVE:
			return move_runner
		System.Belong.ROTATE:
			return move_runner
	return null
