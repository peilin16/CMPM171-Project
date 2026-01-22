extends VFX_request
class_name Shoot_VFX_request

@export var block_time: float = 0.0
var _timer:float = 0;

func _init(vfx: String = "", life: float = 1,sc_min:float = 1, sc_max:float = 1) -> void:
	#use_global_position = false;
	super._init(vfx,life,sc_min,sc_max);
	
func shoot_configure_setting(_block_time:float = 0) -> void:

	block_time = _block_time;
	if block_time == 0 and lifetime != 0:
		block_time = lifetime;
	

func blocking(delta:float)->bool:
	if _timer < lifetime:
		_timer += delta;
		return false;
	return true;
