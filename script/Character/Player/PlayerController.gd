extends Character_controller
class_name  Player_controller


@onready var hurtbox: Area2D = $HurtBox
@onready var vfx_parser: VFX_spawner = $VFXSpawner;
@onready var scheduler: Scheduler = $Scheduler;
@onready var state_hub:State_hub = $StateHub;
@export var logic:Player_logic;
var input_vector := Vector2.ZERO;
#re spawn
var is_behit: bool = false
var move_data:Move_data;

func _init() -> void:
	_character = Player.new();
	logic = Player_logic.new(self,_character);
	team = TEAM.PLAYER;
	move_data = Move_data.new();

func _ready() -> void:
	GameManager.player_manager.register_player(self);
	#animation.bind_logic(_logic)  
	state_hub.set_up_root(Player_state.new());
	#print(GameManager.cursor_manager.get_mouse_world_pos());
	GameManager.cursor_manager.on(GameManager.cursor_manager.EVT_LMB_DOWN, "player_shoot", Callable(self, "player_shooting"));
	move_data.reset(global_position);
	
	
func move(delta: float, speed:float = _character.player_velocity) -> void:
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	velocity = input_vector * speed 
	move_and_slide();
	move_data.record_motion(global_position,delta);
	move_data.print_data();
	
	
func avoid(delta:float) -> void:
	pass

func player_shooting(payload: Dictionary) -> void:
	#print("左键按下 world_pos=", payload["world_pos"])
	var shoot_script:Array = logic.get_shoot_script(payload["world_pos"]);
	#caster.
	scheduler.preemption(shoot_script)
	
func shoot(bullet_script:Array)->void:
	if scheduler.is_running:
		scheduler.preemption(bullet_script);
	else:
		scheduler.setup(bullet_script);
		scheduler.start();
