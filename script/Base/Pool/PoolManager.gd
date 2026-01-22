extends Node
class_name  Pool_manager



@onready var bullet_pool_manager: Node = $BulletPoolManager
@onready var enemy_pool_manager: Node = $EnemyPoolManager
@onready var vfx_pool_manager: Node = $VFXPoolManager
@onready var widget_pool_manager:Node = $WidgetPoolManager
var custom_pool: Dictionary={};
func _ready():
	print("pool ready.")
