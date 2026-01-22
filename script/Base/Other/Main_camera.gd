extends Camera2D
class_name Main_camera

@export var lock_position: bool = true
@export var lock_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	make_current()
	position_smoothing_enabled = false
	rotation_smoothing_enabled = false

	if GameManager and GameManager.camera_manager:
		GameManager.camera_manager.register_camera(self)

	if lock_position:
		global_position = lock_pos

func _process(_delta: float) -> void:
	if lock_position and global_position != lock_pos:
		global_position = lock_pos
