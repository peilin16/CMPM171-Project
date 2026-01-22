extends Item
class_name Bullet
#Bullet.gd
enum BulletColor {
	BLUE,
	RED,
	GREEN
}
enum Faction { PLAYER, ENEMY }

@export var faction: Faction = Faction.ENEMY
@export var damage: int = 5

@export var owner_id: int;
@export var is_active :bool= false;
@export var is_red: bool = false;
@export var can_hurt:bool = true;
@export var current_color := BulletColor.BLUE;
@export var move_data:Move_data; #pattern recorder
#@export var position: Vector2;
#@export var speed: int = 300

#move pattern
#@export var move_cfg:Move_configure;
@export var bullet_scene: PackedScene
@export var pool_name: String;
@export var is_reflect = false;
@export var is_off_screen := true;
@export var knockback_force: float = 300.0     # force
@export var hit_torque_deg: float = 45.0       # rotate



var origin; # shooter

#vfx
@export var explosion_vfx:VFX_request;
@export var eliminate_vfx:VFX_request;

func _init() -> void:
	faction  = Faction.ENEMY
	damage  = 5
	is_active= false;
	is_red = false;
	current_color = BulletColor.BLUE;
	is_reflect = false;
	is_off_screen = true;
	knockback_force = 300.0     # force
	hit_torque_deg = 45.0       # rotate
	move_data = Move_data.new();
	explosion_vfx = VFX_request.new();
	explosion_vfx.vfx_name = "BulletExplosion2"
	explosion_vfx.is_front = true
	#explosion_vfx.spawn_position = controller.global_position
	explosion_vfx.scale_min = 0.6
	explosion_vfx.scale_max = 0.6
	explosion_vfx.lifetime = 0.25
	#controller.vfx_spawner.spawn(vfx)
	
	
func _update_texture(state):
	pass
