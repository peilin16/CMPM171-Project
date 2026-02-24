extends Node2D
class_name Sub_director

#@onready var background_director: Background_director = $BackgroundDirector
#@onready var voice_director: Voice_director = $VoiceDirector
@onready var spawn_director: Spawn_director = _resolve_spawn_director()

func _resolve_spawn_director() -> Spawn_director:
	var node = get_node_or_null("SpawnDirectgor");
	if node == null:
		node = get_node_or_null("SpawnDirector");
	return node as Spawn_director
#@export var anim_runner: AnimRunner
