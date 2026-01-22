extends Node
class_name  PlayerManager


var player: Player_controller = null
@export var player_scene: PackedScene


func _ready() -> void:
	await get_tree().process_frame
	#_spawn_player()

func register_player(p: Player_controller) -> void:
	player = p
	print("Player registered:", player)

func get_player() -> Player_controller:
	return player;
	
func get_player_position() -> Vector2:
	return player.get_actor_position();



func _spawn_player(level: Level_controller, position:Vector2 = Vector2.ZERO):
	if player: player.queue_free()
	player = player_scene.instantiate()
	#var actors := _get_actors_root()
	level.add_child(player);
	player.global_position = position
