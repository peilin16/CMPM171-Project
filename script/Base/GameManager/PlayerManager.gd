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

func unregister_player(p: Player_controller) -> void:
	if player == p:
		player = null

func get_player() -> Player_controller:
	if player == null:
		return null
	if not is_instance_valid(player):
		player = null
		return null
	return player;
	
func get_player_position() -> Vector2:
	var current_player: Player_controller = get_player()
	if current_player == null:
		return Vector2.ZERO
	return current_player.get_actor_position();

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
	var existing_player := get_player()
	if existing_player:
		existing_player.queue_free()
	player = null
	player = player_scene.instantiate()
	#var actors := _get_actors_root()
	level.add_child(player);
	player.global_position = position
	player_score = 0;
