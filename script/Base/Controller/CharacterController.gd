extends CharacterBody2D
class_name Character_controller  
 
var _character:Character;
var controller_id:int;#id
var is_death:bool = false;
var _hurt_flash_tween: Tween

@export var hurt_flash_color: Color = Color(1.0, 0.25, 0.25, 1.0)
@export var hurt_flash_duration: float = 0.12

enum TEAM {
	PLAYER,
	ENEMY,
	NEUTRAL
}
#@onready var state_hub: State_hub = $StateHub;
@export var team = TEAM.ENEMY;
var hitable:bool = false;

func _init() ->void:
	controller_id = ToolBar.gameIDGenerator.generate_id();
	if _character == null:
		_character = Character.new();
	

func behit(bullet:Bullet):
	pass

func _ready() -> void:
	pass

func get_actor_obj() -> Object:
	return _character;

#for order system only
func get_actor_position() -> Vector2:
	return global_position

func set_actor_position(p: Vector2) -> void:
	global_position = p

func get_forward_dir() -> Vector2:
	return Vector2.RIGHT  

func is_alive() -> bool:
	return false;
	
func get_id() ->int:
	return controller_id;

func override_data(o) -> void:
	_character = o;

func play_hurt_flash() -> void:
	if not is_inside_tree():
		return
	if _hurt_flash_tween and _hurt_flash_tween.is_running():
		_hurt_flash_tween.kill()
	modulate = hurt_flash_color
	_hurt_flash_tween = create_tween()
	_hurt_flash_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), max(hurt_flash_duration, 0.01))
