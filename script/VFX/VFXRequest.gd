# VFX_configure.gd
extends Request
class_name VFX_request

# Which VFX to spawn (match your pool key / effect name)
@export var vfx_name: String = ""      # e.g. "MuzzleFlash2"

# Spawn position control
@export var spawn_position: Vector2 = Vector2.ZERO
@export var local_offset: Vector2 = Vector2.ZERO

# Visual params
@export var scale_min: float = 1;
@export var scale_max: float = 1;
@export var lifetime: float = 0.5

# Optional rotation (radians)
@export var rotation_rad: float = 0.0

# Optional: attach to owner (follow)
@export var attach_to_owner: bool = false
#z-index
@export var is_front: bool = true;
@export var amount:int = 0;

func _init(vfx: String = "", life: float = 1,sc_min:float = 1, sc_max:float = 1) -> void:
	belong = System.Belong.VFX   # or create a VFX belong if you want
	# safe defaults
	scale_min = 1;
	scale_max = 1;
	lifetime = 1;
	belong = Belong.VFX;
	vfx_name = vfx;
	lifetime = life;
	scale_min = sc_min
	scale_max = sc_max
# Quick default configure for most one-shot vfx
func simple_setting(vfx: String, pos: Vector2, life: float = 1, sc_min:float = 1, sc_max:float = 1) -> void:
	vfx_name = vfx
	spawn_position = pos
	lifetime = life
	scale_max = sc_max
	scale_min = sc_min

##start spawn  interferce
#func spawn(spawner: VFX_spawner = null) -> void:
	#if spawner == null:
		#return;
	#if vfx_name == "":
		#return
	#spawner.spawn(self)
