extends Node
class_name  PlayerManager


var player: Player_controller = null
@export var player_scene: PackedScene
var _saved_mahjong_hand: Array = []
var _has_saved_mahjong_state: bool = false
var player_score:float = 0

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

func save_mahjong_hand(hand: Array) -> void:
	_saved_mahjong_hand = hand.duplicate(true)
	_has_saved_mahjong_state = true

func get_saved_mahjong_hand() -> Array:
	return _saved_mahjong_hand.duplicate(true)

func has_saved_mahjong_hand() -> bool:
	return _has_saved_mahjong_state

func clear_saved_mahjong_hand() -> void:
	_saved_mahjong_hand.clear()
	_has_saved_mahjong_state = false

func add_score(s:float)->void:
	player_score += s;

func _spawn_player(level: Level_controller, position:Vector2 = Vector2.ZERO):
	if player: player.queue_free()
	player = player_scene.instantiate()
	#var actors := _get_actors_root()
	level.add_child(player);
	player.global_position = position
	player_score = 0;
