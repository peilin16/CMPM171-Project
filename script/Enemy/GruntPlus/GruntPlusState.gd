extends Enemy_state
class_name GruntPlusState

func get_grunt_plus_controller(controller) -> GruntPlusController:
	if controller is GruntPlusController:
		return controller as GruntPlusController
	return null

func get_stats(controller) -> Dictionary:
	return (controller as Enemy_controller).stats
