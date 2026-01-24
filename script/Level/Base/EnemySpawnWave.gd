# Enemy_spawn_wave.gd
extends Wave
class_name Enemy_spawn_wave

@export var enemy_name: String;
@export var spawn_count: int = 1
@export var spawn_interval: float = 0.0
@export var position: Vector2;
@export var behavior_code: String = ""   # 
@export var override: Enemy;        #

var _spawned: int = 0
var _elapsed:float = 0 ;

func enemy_spawn_wave_configure(name:String, _position:Vector2, _behavior_code:String,  count:int = 1, interval:float = 0, _override:Enemy = null)-> void:
	enemy_name = name;
	position = _position;
	spawn_count = count;
	spawn_interval = interval;
	override = _override;
	behavior_code = _behavior_code;

func start(sub: Sub_director) -> void:
	_spawned = 0;

	
	_is_ready = true

func update(sub: Sub_director, delta: float) -> bool:
	if not _is_ready or _spawned >= spawn_count:
		return true;
	_elapsed += delta
	if _elapsed >= spawn_interval:
		_elapsed = 0;
		_spawned += 1;
		sub.spawn_director.spawn_enemy(enemy_name, position ,behavior_code ,override);
	return false


func end(sub: Sub_director) -> void:
	
	pass


	
