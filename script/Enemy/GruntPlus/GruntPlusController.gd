extends Enemy_controller
class_name GruntPlusController

@onready var state_hub: State_hub = $StateHub

# Runtime State Variables
var idle_timer: float = 0.0
var ready_to_shoot: bool = true

# Dependencies
# Using a simple preloaded bullet for this example
var bullet_scene = preload("res://scenes/Bullet/MediumRoundBullet.tscn")

# Avoidance
var ray_center: RayCast2D
var ray_left: RayCast2D
var ray_right: RayCast2D

func _init() -> void:
	name = "GruntPlus"
	_character = GruntPlus.new()
	_logic = enemy_logic.new(self, _character)
	team = TEAM.ENEMY

func _ready() -> void:
	super._ready()
	_setup_avoidance()
	print("GruntPlus Ready with stats: ", stats)

func activate(behavoir_code: String = "", sprite_code: int = 0) -> void:
	# Build State Machine
	# Root: Selector
	var selector = State_selector.new()
	selector.state_name = "GruntPlusSelector"
	
	# Child 1: Idle (Highest Priority if active)
	var idle_state = GruntPlusIdleState.new()
	idle_state.priority = 30
	selector.child_states.append(idle_state)
	
	# Child 2: Shoot (Medium Priority)
	var shoot_state = GruntPlusShootState.new()
	shoot_state.priority = 20
	selector.child_states.append(shoot_state)
	
	# Child 3: Move (Default/Lowest)
	var move_state = GruntPlusMoveState.new()
	move_state.priority = 10
	selector.child_states.append(move_state)
	selector.default_state = move_state
	
	state_hub.set_up_root(selector)
	super.activate(behavoir_code)

func spawn_bullet() -> void:
	if not bullet_scene: return
	
	# Instantiate Bullet
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	# Determine Direction
	var aim_angle = 0.0
	if GameManager.player_manager and GameManager.player_manager.player:
		var target = GameManager.player_manager.get_player_position()
		var dir = (target - global_position).normalized()
		aim_angle = rad_to_deg(dir.angle())
		
	# Setup Movement Script for Scheduler
	var move_script = [
		{
			"action": "move", 
			"type": "direction_linear", 
			"angle": aim_angle, 
			"speed": 300, 
			"duration": 5.0 # Lifetime
		}
	]
	
	# Initialize bullet logic
	if bullet.has_method("activate"):
		# Assuming BulletController has a 'scheduler' property (found in docs/research)
		if bullet.get("scheduler"):
			bullet.scheduler.setup(move_script)
		bullet.activate()

func _setup_avoidance() -> void:
	if stats.get("avoidance_enabled", false) == false: return
	if has_node("AvoidanceRays"): return
		
	var container = Node2D.new()
	container.name = "AvoidanceRays"
	add_child(container)
	
	var ray_length = stats.get("ray_length", 60.0)
	var side_angle = stats.get("side_ray_angle", 30.0)

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
	ray.collision_mask = 1 
	ray.add_exception(self)
	return ray
