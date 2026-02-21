extends Node2D
class_name Spawn_director

#container
@export var enemy_container:Node2D ;
@export var bullet_container:Node2D ;
var enemy_pool_manager: Enemy_pool_manager;


var spawn_points:Dictionary[int,Spawn_point] = {}





func _ready() -> void:
	enemy_pool_manager = PoolManager.enemy_pool_manager;
	if enemy_container == null:
		enemy_container = get_tree().current_scene.get_node_or_null("EnemyContainer") as Node2D
	if bullet_container == null:
		bullet_container = get_tree().current_scene.get_node_or_null("BulletContainer") as Node2D
	var id:int = 0;
	for child in get_children():
		if child.name.begins_with("SpawnPoint"):
			spawn_points[id] = child;
			id +=1;





func spawn_enemy(name:String, _position:Vector2 ,behavior_code:String = "", texture_code:int = 0 , override: Enemy = null) -> void:
	var _enemy_pool = enemy_pool_manager.get_pool(name);
	if _enemy_pool == null:
		return
	var enemy = _enemy_pool.spawn_enemy();
	if enemy == null:
		return
	
	if not override == null:
		enemy.override_data(override);
	
	enemy.set_actor_position(_position);
	if enemy_container == null:
		enemy_container = get_tree().current_scene
	enemy_container.add_child(enemy);
	enemy.activate(behavior_code,texture_code);
