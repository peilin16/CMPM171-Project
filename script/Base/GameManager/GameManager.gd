# GameManager.gd
extends Node
class_name game_manager   

signal accessibility_mode_changed(mode: String)

@onready var bullet_manager: BulletManager = $BulletManager
@onready var player_manager: PlayerManager = $PlayerManager
@onready var enemy_manager: EnemyManager =$EnemyManager
@onready var ui_manager: Node = $UIManager
@onready var level_manager: LevelManager =  $LevelManager
@onready var vfx_manager: Node =  $VFXManager
@onready var camera_manager: Camera_manager = $CameraManager
@onready var cursor_manager:Cursor_manager = $CursorManager
@onready var accessibility_manager: AccessibilityManager = $AccessibilityManager

func _ready():
	print("GameManager ready.")

func set_colorblind_mode(mode: String) -> void:
	accessibility_manager.set_colorblind_mode(mode)

func get_colorblind_mode() -> String:
	return accessibility_manager.get_colorblind_mode()
