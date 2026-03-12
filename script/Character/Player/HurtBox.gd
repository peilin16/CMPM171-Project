extends Area2D
class_name Hurt_box

var can_hurt:bool = false;
@onready var sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D
var tween: Tween;
@export var player_hp:float = 100; 
var controller:Player_controller;
@export var contact_damage: float = 3.0
@export var contact_damage_interval: float = 1.0

var _contact_damage_timer: float = 0.0
var _touching_enemies: Array[Enemy_controller] = []
func open()->void:
	can_hurt = true;

func close()->void:
	can_hurt = false;

func _ready():
	
	player_hp = 100;
	if sprite:
		sprite.modulate = Color(1, 1, 1, 0)  
		sprite.visible = false  # hide
	can_hurt = true;
	controller = get_parent();
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

func _on_area_entered(area: Area2D) -> void:
	if area is Widget_controller:
		controller.logic.add_score(5);
		return;
	 # Replace with function body.

func hurt(num:float)->void:
	if num <= 0:
		return
	var reduction := 0.0
	if controller and controller.logic:
		reduction = controller.logic.get_damage_reduction()
	player_hp -= num * (1.0 - reduction)
	if controller:
		controller.play_hurt_flash()
	if GameManager.camera_manager:
		GameManager.camera_manager.shake(10.0, 10.0, 0.2) 

func _physics_process(delta: float) -> void:
	if not can_hurt:
		return

	_clear_invalid_enemies()
	if _touching_enemies.is_empty():
		_contact_damage_timer = 0.0
		return;

	_contact_damage_timer += delta
	if _contact_damage_timer >= contact_damage_interval:
		_apply_contact_damage()
		_contact_damage_timer = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body is not Enemy_controller:
		return;
	if not can_hurt:
		return;
	var enemy := body as Enemy_controller
	if not _touching_enemies.has(enemy):
		_touching_enemies.append(enemy)
	_apply_contact_damage()

func _on_body_exited(body: Node2D) -> void:
	if body is not Enemy_controller:
		return
	var enemy := body as Enemy_controller
	_touching_enemies.erase(enemy)
	if _touching_enemies.is_empty():
		_contact_damage_timer = 0.0

func _clear_invalid_enemies() -> void:
	_touching_enemies = _touching_enemies.filter(func(enemy: Enemy_controller) -> bool:
		return is_instance_valid(enemy)
	)

func _apply_contact_damage() -> void:
	if _touching_enemies.is_empty():
		return
	hurt(contact_damage)
