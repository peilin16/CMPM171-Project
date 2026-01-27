extends Enemy
class_name Generic_fairy1

var death_vfx_scipt:={
	"name":"Explosion3",
	"scale_min":1,
	"scale_max":1,
	"life":1.5,
	"front":true
}

func _init() -> void:
	super._init();
	max_hp = 2
	hp = max_hp
	
