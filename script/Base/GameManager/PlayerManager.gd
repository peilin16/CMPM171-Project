extends Node
class_name  PlayerManager


var player: Player_controller = null
@export var player_scene: PackedScene
var _saved_mahjong_hand: Array = []
var _has_saved_mahjong_state: bool = false
var _saved_player_hp: float = 100.0
var _has_saved_player_hp: bool = false
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
	clear_saved_player_hp()

func reset_run_state() -> void:
	clear_saved_mahjong_hand()
	clear_saved_player_hp()
	player_score = 0

func save_player_hp(hp: float) -> void:
	_saved_player_hp = max(hp, 0.0)
	_has_saved_player_hp = true

func consume_saved_player_hp(default_hp: float = 100.0) -> float:
	if not _has_saved_player_hp:
		return default_hp
	var hp := _saved_player_hp
	_has_saved_player_hp = false
	_saved_player_hp = default_hp
	return hp

func clear_saved_player_hp() -> void:
	_saved_player_hp = 100.0
	_has_saved_player_hp = false

func save_current_player_state() -> void:
	var current_player := get_player()
	if current_player == null:
		return
	var hurt_box := current_player.get_node_or_null("HurtBox") as Hurt_box
	if hurt_box:
		save_player_hp(hurt_box.player_hp)

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
	var hurt_box := player.get_node_or_null("HurtBox") as Hurt_box
	if hurt_box:
		hurt_box.player_hp = consume_saved_player_hp(hurt_box.player_hp)
