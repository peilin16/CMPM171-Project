# Enemy_spawn_wave.gd
extends Wave
class_name Enemy_spawn_wave

@export var enemy_name: String;
@export var spawn_count: int = 1
@export var spawn_interval: float = 0.0
@export var position: Vector2;
@export var behavior_code: String = ""   # 
@export var override: Enemy;        #
#texture random
@export var texture_type_range_min:int = 0
@export var texture_type_range_max:int = 0
@export var random_seed:int = 0
var random_generator:Random_single_int = Random_single_int.new();
var _spawned: int = 0
var _elapsed:float = 0 ;
var is_finish:bool = false;
var current_texture_code:int = 0
var is_random:bool = false;
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
	if texture_type_range_min != texture_type_range_max:
		is_random =false
		random_generator.set_seed_index(random_seed);
		random_generator.setting(texture_type_range_min,texture_type_range_max);


func update(sub: Sub_director, delta: float) -> void:
	if not _is_ready or _spawned >= spawn_count:
		is_finish = true;
		return;
	_elapsed += delta
	if _elapsed >= spawn_interval:
		_elapsed = 0;
		_spawned += 1;
		current_texture_code = random_generator.get_random_int();
		sub.spawn_director.spawn_enemy(enemy_name, position ,behavior_code,current_texture_code ,override);
	is_finish = false;

func is_done(sub: Sub_director) ->bool:
	return is_finish;

	
