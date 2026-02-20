extends Enemy_state
class_name StoneLionState

func get_stone_lion_controller(controller) -> StoneLionController:
	if controller is StoneLionController:
		return controller as StoneLionController
	return null

func get_stats(controller) -> Dictionary:
	return (controller as Enemy_controller).stats
