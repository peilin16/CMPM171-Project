# VFX_emit_order.gd
extends Order
class_name VFX_emit_order

var req: VFX_request
var spawner: VFX_spawner
var owner_controller
var follow: bool = false
var offset: Vector2 = Vector2.ZERO
var _inst: VFX_instance = null
var _started := false
@export var request:Request;


func _init( r:Request) -> void:
	request = r;
	
func setup(_spawner: VFX_spawner, _req: VFX_request, _owner, _follow: bool, _offset: Vector2) -> void:
	spawner = _spawner
	req = _req
	owner_controller = _owner
	follow = _follow
	offset = _offset

func start(actor, _runner: Task_runner) -> void:
	_started = false

func update(actor, _runner: Task_runner, delta: float) -> bool:
	if spawner == null or req == null:
		return true

	# spawn once
	if not _started:
		_started = true

		# compute spawn position: owner + offset
		if owner_controller != null:
			req.spawn_position = owner_controller.get_actor_position() + offset

		_inst = spawner.spawn(req)
		# 如果是 follow：持续存在直到外部 stop（这里先不自动结束）
		if follow:
			return true  # 这个 order 结束，但实例会继续跟随（由 scheduler 管理）
		return true

	return true
