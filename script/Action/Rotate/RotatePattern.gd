# Rotate_pattern.gd
extends Pattern
class_name Rotate_pattern
var rotate_runner:Rotate_runner;
var rotate_configure:Rotate_configure;
var record: Rotate_data

func _ready(runner: Runner, configure: Configure) ->void:
	if not rotate_runner:
		rotate_runner = runner as Rotate_runner
	if not rotate_configure:
		rotate_configure = configure as Rotate_configure
	rotate_runner.is_ready = true;
	if not record:
		record = Rotate_data.new();
	record.current_deg = rotate_configure.start_deg;
