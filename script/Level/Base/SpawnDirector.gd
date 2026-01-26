extends Node2D
class_name Spawn_director

#container
@export var enemy_container:Node2D ;
@export var bullet_container:Node2D ;
var enemy_pool_manager: Enemy_pool_manager;

func _ready() -> void:
	enemy_pool_manager = PoolManager.enemy_pool_manager;






func spawn_enemy(name:String, _position:Vector2 ,behavior_code:String = "", texture_code:int = 0 , override: Enemy = null) -> void:
	var _enemy_pool = enemy_pool_manager.get_pool(name);
	var enemy = _enemy_pool.spawn_enemy();
	
	if not override == null:
		enemy.override_data(override);
	
	enemy.set_actor_position(_position);
	enemy_container.add_child(enemy);
	enemy.activate(behavior_code,texture_code);
