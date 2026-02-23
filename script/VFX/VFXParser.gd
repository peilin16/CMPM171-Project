# VFX_scheduler.gd
extends Node2D
class_name VFX_parser

#@onready var task_runner: Task_runner = $TaskRunner
@onready var spawner = $VFXSpawner
var _built_request: VFX_request;
var parent_controller

func _ready() -> void:
	parent_controller = get_parent();

func get_request()->VFX_request:
	return _built_request;



func setup(d: Dictionary) -> VFX_request:
	_built_request = VFX_request.new();
	execute(d);
	return _built_request;


func _apply_base(d: Dictionary) -> void:

	_built_request.vfx_name = d.get("name", d.get("vfx_name", "MuzzleFlash2"))
	_built_request.spawn_position= d.get("spawn_position", d.get("position", Vector2(999999,99999)));
	if _built_request.spawn_position== Vector2(999999,99999):
		_built_request.spawn_position = get_actor_position();
	_built_request.local_offset = d.get("offset", Vector2.ZERO);
	if d.has("scale"):
		var s :float =  d.get("scale", 1);
		_built_request.scale_min = s ;
		_built_request.scale_max= s ;
	else:
		_built_request.scale_min= float(d.get("scale_min",d.get("min", 1.0)))
		_built_request.scale_max= float(d.get("scale_max",  d.get("max",  1.0)))

	_built_request.lifetime =  float(d.get("life", 0.15))
	_built_request.is_front = bool(d.get("front", true));
	var raw_rotation = d.get("rotate", d.get("rad", d.get("rotate_rad", 0.0)))
	if raw_rotation is Vector2:
		_built_request.rotation_rad = raw_rotation.angle()
	else:
		_built_request.rotation_rad = float(raw_rotation)
	_built_request.attach_to_owner = bool(d.get("follow", d.get("attach", false)))

func _build_simple_request(d: Dictionary) -> void:
	_built_request = VFX_request.new();
	_apply_base(d);
	


func  _build_shoot_request(d: Dictionary) -> void:
	_built_request = Shoot_VFX_request.new();
	_apply_base(d);
	_built_request.block_time =  float(d.get("block", 0));
	if _built_request.block_time ==0:
		_built_request.block_time = _built_request.lifetime;
	spawner.spawn(_built_request);

func execute(d: Dictionary) :
	var mode := str(d.get("mode", "vfx"))
	match  mode:
		"vfx","simple":
			_build_simple_request(d);
		"shoot","shooting":
			_build_shoot_request(d);
	spawner.spawn(_built_request);


# -------------------------
# Duck-type bridge for runners / patterns
# -------------------------
func get_actor_obj() -> Object:
	return parent_controller.get_actor_obj()

func get_actor_position() -> Vector2:
	return parent_controller.global_position

func set_actor_position(p: Vector2) -> void:
	parent_controller.global_position = p

func get_id() -> int:
	return parent_controller.controller_id
