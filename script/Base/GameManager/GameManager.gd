# GameManager.gd
extends Node
class_name game_manager   


@onready var bullet_manager: BulletManager = $BulletManager
@onready var player_manager: PlayerManager = $PlayerManager
@onready var enemy_manager: EnemyManager =$EnemyManager
@onready var ui_manager: Node = $UIManager
@onready var level_manager: LevelManager =  $LevelManager
@onready var vfx_manager: Node =  $VFXManager
@onready var camera_manager: Camera_manager = $CameraManager
@onready var cursor_manager:Cursor_manager = $CursorManager

func _ready():
	print("GameManager ready.")
