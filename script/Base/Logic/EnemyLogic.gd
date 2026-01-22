extends Character_logic
class_name enemy_logic;

signal hp_changed(current: int, max: int)
signal died
signal hit_applied(amount: int)

var caster:Cast_scheduler;
var movement:Movement_scheduler
var behavoir:String;
var queue: Array[Order] = [];

func _init(_controller, _character: Character) -> void:
	controller = _controller;
	character = _character as Enemy;
func _set_hp(v: int) -> void:
	character.hp = clamp(v, 0, character.max_hp)
	emit_signal("hp_changed", character.hp, character.max_hp)
	if character.hp <= 0:
		emit_signal("died")

func set_up_caster(c:Cast_scheduler)->void:
	caster = c;
func set_up_move(m:Movement_scheduler)->void:
	movement = m;
#func apply_damage(amount: int) -> void:
	#if amount <= 0: return
	#_set_hp(data.hp - amount)
	#

func apply_behavior(code: String = "") -> void:
	behavoir = code

func _build_behavior_default() -> void:
	var move_cfg := Move_configure.new()
	move_cfg._simple_configure_for_direction(controller.get_actor_position(), 100.0, 90.0)
	var move_pattern := Linear_move_pattern.new()
	var move_order := Order.new()
	move_order.system_configure = move_cfg
	move_order.system_pattern = move_pattern
	move_order.duration = 5.0
	queue.append(move_order);


func reset() ->void:
	queue.clear();
	behavoir = "";	
func behit(bullet: Bullet)-> void:
	#emit_signal("hit_applied", bullet.damage)
	apply_damage(bullet.damage);
	
func apply_damage(damage:float) ->void:
	character.hp = character.hp - damage;
		
func get_queue() -> Array[Order]:
	return queue;
