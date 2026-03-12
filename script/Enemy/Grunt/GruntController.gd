extends Enemy_controller
class_name GruntController

@onready var state_hub: State_hub = $StateHub

func _init() -> void:
	name = "Grunt"
	enemy_type_name = "Grunt"
	_character = Grunt.new()
	_logic = enemy_logic.new(self, _character)
	team = TEAM.ENEMY

func _ready() -> void:
	super._ready()

func activate(behavoir_code: String = "", sprite_code: int = 0) -> void:
	var state = GruntChaseState.new()
	state_hub.set_up_root(state)
	super.activate(behavoir_code)
