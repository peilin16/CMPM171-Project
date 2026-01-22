# VFX_controller_spawner.gd
extends VFX_spawner
class_name VFX_controller_spawner

@export var default_offset: Vector2 = Vector2.ZERO
@export var default_front: bool = true
@export var default_attach_to_owner: bool = false   # true: add_child to owner; false: VFXContainer
@export var auto_follow: bool = true                # if spawn_follow, keep updating position

var controller: Node = null
var _follow_inst: VFX_instance = null
var _follow_offset: Vector2 = Vector2.ZERO
var _follow_rotation: float = 0.0
var _follow_front: bool = true
var _follow_attach: bool = false
var _is_following: bool = false

func _ready() -> void:
	super._ready()
	controller = get_parent()

func _physics_process(_delta: float) -> void:
	if not _is_following:
		return
	if _follow_inst == null or not is_instance_valid(_follow_inst):
		_is_following = false
		_follow_inst = null
		return
	if controller == null or not is_instance_valid(controller):
		return

	_follow_inst.global_position = _get_owner_pos() + _follow_offset
	_follow_inst.rotation = _follow_rotation;
	
	
func spawn(cfg: VFX_request) -> VFX_instance:
	cfg.spawn_position = _get_owner_pos();
	return super.spawn(cfg);
# -------------------------
# One-shot at owner position + offset
# -------------------------
func emit_at_owner(vfx_name: String, life: float = 0.25, offset: Vector2 = Vector2.ZERO, is_front: bool = true) -> VFX_instance:
	var cfg := VFX_request.new()
	cfg.vfx_name = vfx_name
	cfg.lifetime = life
	cfg.is_front = is_front
	cfg.attach_to_owner = false
	cfg.spawn_position = _get_owner_pos() + offset
	return spawn(cfg)

# -------------------------
# Spawn a persistent VFX that follows owner (tail/charging ring)
# -------------------------
func start_follow(vfx_name: String, offset: Vector2 = Vector2.ZERO, is_front: bool = true, attach_to_owner: bool = false, rotation_rad: float = 0.0, life: float = 9999.0) -> VFX_instance:
	# If already following, clear first (avoid double tails)
	clear_follow(true)

	var cfg := VFX_request.new()
	cfg.vfx_name = vfx_name
	cfg.is_front = is_front
	cfg.attach_to_owner = attach_to_owner
	cfg.rotation_rad = rotation_rad
	cfg.lifetime = life
	cfg.spawn_position = _get_owner_pos() + offset
	cfg.follow_owner = true
	cfg.local_offset = offset

	var inst := spawn(cfg)
	if inst == null:
		return null

	_follow_inst = inst
	_follow_offset = offset
	_follow_rotation = rotation_rad
	_follow_front = is_front
	_follow_attach = attach_to_owner
	_is_following = auto_follow

	# Make sure it is emitting
	inst.start_emitting()
	return inst

func stop_follow(stop_emit_only: bool = true) -> void:
	if _follow_inst == null or not is_instance_valid(_follow_inst):
		_is_following = false
		_follow_inst = null
		return

	_is_following = false

	if stop_emit_only:
		_follow_inst.stop_emitting()
	else:
		# Immediately return to pool if you want
		_follow_inst.deactivate_to_pool()

func clear_follow(stop_emit_only: bool = true) -> void:
	stop_follow(stop_emit_only)

# -------------------------
# Emitting control (for charging start/stop)
# -------------------------
func start_emitting() -> void:
	if _follow_inst and is_instance_valid(_follow_inst):
		_follow_inst.start_emitting()

func stop_emitting() -> void:
	if _follow_inst and is_instance_valid(_follow_inst):
		_follow_inst.stop_emitting()

# -------------------------
# Helpers
# -------------------------
func _get_owner_pos() -> Vector2:
	# Your controllers already have get_actor_position()
	if controller:
		return controller.get_actor_position()
	return global_position
