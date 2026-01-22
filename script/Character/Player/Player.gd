extends Character
#Player.gd
class_name Player
#speed
@export  var player_velocity :float= 320.0;
#@export var rumia_slow_velocity:float = 80;
#@export  var rumia_accleration :float= 400.0;

@export  var defence :bool= false

@export var coldDown: int = 4;
@export var isColdDown:bool= false;


@export var respawn_delay_sec: float = 2.0
@export var invincible_sec: float = 3.0          
@export var initial_shield_sec: float = 5.0       
@export var respawn_move_speed: float = 650.0

@export var power:float = 0;
@export var score:float = 0;

func _init() -> void:
	isEnemy = false;
	
