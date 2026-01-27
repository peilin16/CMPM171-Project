extends Node2D
class_name VFX_instance

@export var lifetime: float = 0.25
@export var auto_play: bool = true  # 是否在ready时自动播放
@export var stop_on_finish: bool = true  # 结束后是否停止粒子

@onready var particles_array: Array[GPUParticles2D] = []

var _t: float = 0.0
var _pool: VFX_pool = null
var _is_playing: bool = false

func _ready() -> void:
	# 自动收集所有GPUParticles2D子节点
	_collect_particles()
	z_index = 500
	if auto_play:
		play()

func _collect_particles() -> void:
	particles_array.clear()
	
	# 收集所有GPUParticles2D节点（包括子节点的子节点）
	_collect_particles_recursive(self)

func _collect_particles_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is GPUParticles2D:
			particles_array.append(child)
		
		# 递归搜索子节点
		if child.get_child_count() > 0:
			_collect_particles_recursive(child)


# VFX_instance.gd (suggest)
func start_emitting() -> void:
	for child in particles_array:
		child.emitting = true

func stop_emitting() -> void:
	for child in particles_array:
		child.emitting = false

func set_up_scale(scale_min:float, scale_max:float)->void:
	for particle in particles_array:
		particle.process_material.scale_min = scale_min
		particle.process_material.scale_max = scale_max
func bind_pool(p: VFX_pool) -> void:
	_pool = p

func set_lifetime(t: float) -> void:
	lifetime = max(t, 0.01)

func play() -> void:
	_t = 0.0
	_is_playing = true
	
	# 启动所有粒子系统
	_start_all_particles()

func _start_all_particles() -> void:
	for particles in particles_array:
		if particles:
			particles.emitting = false
			particles.restart()
			particles.emitting = true

func _physics_process(delta: float) -> void:
	if not _is_playing:
		return
	
	_t += delta
	
	# 检查是否结束
	if _t >= lifetime:
		_recycle()

func _recycle() -> void:
	_is_playing = false
	
	# 停止所有粒子
	if stop_on_finish:
		for particles in particles_array:
			if particles:
				particles.emitting = false
	
	if _pool != null:
		_pool.recycle(self)
	else:
		queue_free()
