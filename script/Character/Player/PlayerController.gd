extends Character_controller
class_name  Player_controller


@onready var hurtbox: Area2D = $HurtBox
@onready var vfx_parser: VFX_spawner = $VFXSpawner;
@onready var Caster: Cast_scheduler = $CastScheduler;


var input_vector := Vector2.ZERO;
#re spawn
var is_behit: bool = false


func _init() -> void:
	if _character == null:
		_character = Player.new();
	logic = Player_logic.new(self,_character);
	team = TEAM.PLAYER;
	controller_id =ToolBar.gameIDGenerator.generate_id();
