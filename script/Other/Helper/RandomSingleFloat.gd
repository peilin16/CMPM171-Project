extends Resource
class_name Random_single_float

var mmax:float
var mmin:float;
var generator = ToolBar.repeatableRandomGenerator;
var _arr:Array[float];
var _seed_index:int = 1;
var decimal:int= 100
var SIZE:int = 20
func setting(_mmax:float, _mmin:float,_decimal:int = 100, start:int = 1):
	mmax = _mmax;
	mmin = _mmin;
	decimal = _decimal;
	_seed_index = start;
	get_new_array();

func get_random_float(_mmax:float = mmax, _mmin:float = mmin)->float:
	if _mmax == _mmin or _seed_index == 0:
		return 0;
	if _arr.is_empty():
		setting(_mmax, _mmin);
	var i = _arr.pop_front();
	if i <= _mmax and i >= _mmin:
		return i;

	return get_random_float(_mmax, _mmin);
	
func set_seed_index(s:int) ->void:
	_seed_index = s;
	
func get_new_array(is_reset:bool = false):
	if _seed_index >= generator.MAX_SEEDS or is_reset:
		_seed_index = 1;
		SIZE = 20;
	_arr = generator.random_float_sequence(SIZE, mmin, mmax,_seed_index,decimal);
	_seed_index += 1;
	SIZE = SIZE * 2;
