extends Enemy_controller
class_name GruntController

@onready var state_hub: State_hub = $StateHub

# Avoidance Rays (created in code to ensure they exist)
var ray_center: RayCast2D
var ray_left: RayCast2D
var ray_right: RayCast2D

func _init() -> void:
	# Basic Properties
	name = "Grunt"
	# Initialize specific Character Data
	_character = Grunt.new()
	# Initialize Logic wrapper 
	_logic = enemy_logic.new(self, _character)
	team = TEAM.ENEMY

func _ready() -> void:
	super._ready()
	
	_setup_avoidance()
	print("Grunt Ready with Stats: ", stats)

func activate(behavoir_code: String = "", sprite_code: int = 0) -> void:
	# Set up the State Machine with our Chase State
	# In a fuller implementation, this might be a StateSelector 
	# that chooses between Chase and Attack.
	var state = GruntChaseState.new()
	state_hub.set_up_root(state)
	
	super.activate(behavoir_code)

func _setup_avoidance() -> void:
	if stats.get("avoidance_enabled", false) == false: return
	
	if has_node("AvoidanceRays"):
		return # Already set up (e.g. from scene)
		
	var container = Node2D.new()
	container.name = "AvoidanceRays"
	add_child(container)
	
	var ray_length = stats.get("ray_length", 50.0)
	var side_angle = stats.get("side_ray_angle", 45.0)

	# Assuming RIGHT is forward (0 degrees)
	ray_center = _create_ray(0, ray_length)
	ray_left = _create_ray(-deg_to_rad(side_angle), ray_length)
	ray_right = _create_ray(deg_to_rad(side_angle), ray_length)
	
	container.add_child(ray_center)
	container.add_child(ray_left)
	container.add_child(ray_right)

func _create_ray(angle: float, length: float) -> RayCast2D:
	var ray = RayCast2D.new()
	ray.target_position = Vector2.RIGHT.rotated(angle) * length
	ray.enabled = true
	# Need collision mask interact with World (usually bit 1)
	# Might need to export this in config if different
	ray.collision_mask = 1 
	# Exclude self? CharacterBody2D is usually a collision object. RayCast2D default exceptions?
	# RayCast2D add_exception(self)
	ray.add_exception(self)
	return ray
