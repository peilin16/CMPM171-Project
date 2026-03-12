extends Enemy_controller
class_name GruntPlusController

@onready var state_hub: State_hub = $StateHub

# Runtime State Variables
var idle_timer: float = 0.0
var ready_to_shoot: bool = true

# Dependencies
const BULLET_POOL_NAME := "MEDIUM_ROUND_BULLET"



func _init() -> void:
	name = "GruntPlus"
	enemy_type_name = "GruntPlus"
	_character = GruntPlus.new()
	_logic = enemy_logic.new(self, _character)
	team = TEAM.ENEMY

func _ready() -> void:
	super._ready()

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
	if PoolManager == null or PoolManager.bullet_pool_manager == null:
		return

	var bullet = PoolManager.bullet_pool_manager.spawn_bullet(BULLET_POOL_NAME)
	if bullet == null:
		return

	var bullet_container = get_tree().current_scene.get_node_or_null("BulletContainer")
	if bullet.get_parent() != bullet_container:
		if bullet.get_parent() != null:
			bullet.get_parent().remove_child(bullet)
		if bullet_container != null:
			bullet_container.add_child(bullet)
		else:
			get_parent().add_child(bullet)

	bullet.set_actor_position(global_position)
	bullet.bullet.origin = self
	bullet.bullet.owner_id = get_id()
	bullet.bullet.faction = bullet.bullet.Faction.ENEMY
	bullet.bullet.current_color = Bullet.BulletColor.RED
	bullet.bullet.is_red = true
	bullet._update_collision()
	
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
		if bullet.scheduler:
			bullet.scheduler.clear()
			bullet.scheduler.setup(move_script)
		bullet.activate()


