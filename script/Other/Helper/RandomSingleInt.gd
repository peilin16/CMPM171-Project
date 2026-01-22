extends Resource
class_name Random_single_int

var mmax:int
var mmin:int;
var generator = ToolBar.repeatableRandomGenerator;
var _arr:Array[int];
var _seed_index:int = 1;
var SIZE:int = 20
func setting(_mmin:int,_mmax:int, start:int = 1):
	mmax = _mmax;
	mmin = _mmin;
	_seed_index = start;
	get_new_array();
	
	
func set_seed_index(s:int) ->void:
	_seed_index = s;
	
	
func get_random_int( _mmin:int = mmin,_mmax:int = mmax)->int:
	if _mmax == _mmin or _seed_index == 0:
		return 0;
	if _arr.is_empty():
		setting(_mmax, _mmin);
	var i = _arr.pop_front();
	if i <= _mmax and i >= _mmin:
		return i;

	return get_random_int(_mmax, _mmin);
	

	
func get_new_array(is_reset:bool = false):
	if _seed_index >= generator.MAX_SEEDS or is_reset:
		_seed_index = 1;
	_arr = generator.random_int_sequence(SIZE, mmin, mmax,_seed_index);
	_seed_index += 1;
	SIZE = SIZE * 2;
