# MovePattern.gd
extends Pattern
class_name Move_pattern

var move_runner: Move_runner
var move_configure: Move_configure
var record: Move_data

func _init() -> void:
	belong = Belong.MOVE

func _ready(runner: Runner, configure: Configure) -> void:
	if not runner:
		move_runner = runner as Move_runner
	if not configure:
		move_configure = configure as Move_configure

	# bind move_data recorder
	if move_runner and move_runner.controller:
		var item = move_runner.controller.get_actor_obj()
		if item and "move_data" in item and item.move_data:
			record = item.move_data
		else:
			record = Move_data.new()
			if item and "move_data" in item:
				item.move_data = record

func play(runner: Runner, configure: Configure, delta: float) -> bool:
	return true # finished by default

func interrupt() -> void:
	pass

func deactivate() -> void:
	pass
