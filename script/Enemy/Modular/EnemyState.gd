extends State_object
class_name Enemy_state

# Helper to avoid repetitive casting
func get_enemy(controller) -> Enemy_controller:
	return controller as Enemy_controller

func get_scheduler(controller) -> Scheduler:
	return (controller as Enemy_controller).scheduler
