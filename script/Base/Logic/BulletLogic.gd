extends Resource
class_name Bullet_logic

var controller:Bullet_controller;
var bullet:Bullet;
#var caster:Cast_scheduler;
var movement:Movement_scheduler


func _init(c:Bullet_controller = null) -> void:
	controller = c;
func set_up_controller(c:Bullet_controller)->void:
	controller = c;
func set_up_obj(b:Bullet)->void:
	bullet = b;
	
#func set_up_caster(c:Cast_scheduler)->void:
	#caster = c;
func set_up_move(m:Movement_scheduler)->void:
	movement = m;

	
func reflect_bullet(current_order:Order)->void:
	var cfg:Move_configure = current_order.configure;
	
	var move_script = [
	  		{
			"type":"target_linear",
			"speed":cfg.max_velocity + cfg.max_velocity * 0.4,
			"is_continue":true,
			"target":bullet.origin.get_actor_position()
	  		}
		];
	movement.preemption(move_script);
	#return new_order;
