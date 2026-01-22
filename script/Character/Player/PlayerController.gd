extends Character_controller
class_name  Player_controller


@onready var hurtbox: Area2D = $HurtBox
@onready var vfx_parser: VFX_spawner = $VFXSpawner;
@onready var caster: Cast_scheduler = $CastScheduler;
@onready var state_hub:State_hub = $StateHub;
@export var logic:Player_logic;
var input_vector := Vector2.ZERO;
#re spawn
var is_behit: bool = false


func _init() -> void:
	_character = Player.new();
	logic = Player_logic.new(self,_character);
	team = TEAM.PLAYER;
	

func _ready() -> void:
	GameManager.player_manager.register_player(self);
	#animation.bind_logic(_logic)  
	state_hub.set_up_root(Player_state.new());
	
func move(delta: float, speed:float = _character.player_velocity) -> void:
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	if Input.is_action_pressed("slow"):
		velocity = input_vector * _character.rumia_slow_velocity;
	else:
		velocity = input_vector * speed #_character.rumia_velocity;
	move_and_slide();

func avoid(delta:float) -> void:
	pass
	
func shoot()->void:
	pass
