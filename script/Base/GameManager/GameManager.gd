# GameManager.gd
extends Node
class_name game_manager   


@onready var bullet_manager: Node = $BulletManager
@onready var player_manager: Node = $PlayerManager
@onready var enemy_manager: Node =$EnemyManager
@onready var ui_manager: Node = $UIManager
@onready var level_manager: Node =  $LevelManager
@onready var vfx_manager: Node =  $VFXManager
@onready var camera_manager: Node = $CameraManager
@onready var cursor_manager:Node = $CursorManager

func _ready():
	print("GameManager ready.")
