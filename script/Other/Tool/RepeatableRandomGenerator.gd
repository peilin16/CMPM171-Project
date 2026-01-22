extends Node
class_name Repeatable_random_generator

const MAX_SEEDS := 200

# Master seed (can be exported if you want to tweak in Inspector)
var master_seed: int = 123456

# Derived seeds
var _seed_list: Array[int] = []


func _ready() -> void:
	_build_seeds()


# Rebuild the 200 seeds based on master_seed
func _build_seeds() -> void:
	_seed_list.clear()

	var rng := RandomNumberGenerator.new()
	rng.seed = master_seed

	for i in range(MAX_SEEDS):
		# Use rng.randi() to derive each seed
		_seed_list.append(rng.randi())


# Allow changing master_seed at runtime (optional)
func set_master_seed(new_seed: int) -> void:
	master_seed = new_seed
	_build_seeds()


# Get a specific seed (clamped)
func get_seed(index: int) -> int:
	index = clamp(index, 0, MAX_SEEDS - 1)
	return _seed_list[index]


# Generic helper: generate a sequence of ints in [min, max]
func random_int_sequence( count: int, mmin: int, mmax: int,seed_index: int =  0) -> Array[int]:
	var result: Array[int] = []

	if count <= 0:
		return result

	seed_index = clamp(seed_index, 0, MAX_SEEDS - 1)

	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_list[seed_index]

	for i in range(count):
		result.append(rng.randi_range(mmin, mmax))

	return result;
	
	
func random_float_sequence( count: int, mmin: float, mmax: float,seed_index: int =  0,decimal:int = 100) -> Array[float]:
	
	seed_index = clamp(seed_index, 0, MAX_SEEDS - 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_list[seed_index]
	
	var result: Array[float] = []
	var range_size = mmax - mmin
	for i in range(count):
		var random_value = rng.randf_range(mmin, mmax)
		
		if decimal > 0:
			random_value = roundf(random_value * decimal) / decimal
		result.append(random_value)
	return result
	
	
#if need
func get_random_one(mmin: int, mmax: int,seed_index: int = 0) ->int:
	var arr = random_int_sequence(5,mmin, mmax,seed_index);
	return arr[0];
	
	
# You can also add a bool sequence helper if needed
func random_bool_sequence(seed_index: int, count: int) -> Array[bool]:
	var result: Array[bool] = []

	if count <= 0:
		return result

	seed_index = clamp(seed_index, 0, MAX_SEEDS - 1)

	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_list[seed_index]

	for i in range(count):
		result.append(rng.randi() % 2 == 0)

	return result
