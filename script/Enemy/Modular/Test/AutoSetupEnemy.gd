extends Enemy_controller
class_name AutoSetupEnemy

func _ready() -> void:
	# 0. Ensure Scheduler Infrastructure exists
	var sched_node = get_node_or_null("Scheduler")
	if not sched_node:
		print("AutoSetupEnemy: Creating missing Scheduler...")
		sched_node = Scheduler.new()
		sched_node.name = "Scheduler"
		
		var runner = Task_runner.new()
		runner.name = "TaskRunner"
		sched_node.add_child(runner)
		
		var subhub = Sub_action_hub.new()
		subhub.name = "SubActionHub"
		runner.add_child(subhub)
		
		# Add required runners to SubActionHub
		var move_runner = Move_runner.new()
		move_runner.name = "MoveRunner"
		subhub.add_child(move_runner)
		
		var rotate_runner = Rotate_runner.new()
		rotate_runner.name = "RotateRunner"
		subhub.add_child(rotate_runner)
		
		var shoot_runner = Shoot_runner.new()
		shoot_runner.name = "ShootRunner"
		subhub.add_child(shoot_runner)
		
		add_child(sched_node)
		# Force assign to parent controller's variable since @onready might have failed/passed already
		scheduler = sched_node

	# 1. Ensure StateHub and Dependencies exist
	var hub = get_node_or_null("StateHub")
	if not hub:
		hub = State_hub.new()
		hub.name = "StateHub"
		
		# StateHub expects an AnimationPlayer child named "AnimationPlayer" in its _ready
		var anim = Animation_player.new()
		anim.name = "AnimationPlayer"
		hub.add_child(anim)
		
		add_child(hub)
		# Note: add_child triggers hub._ready(), which grabs parent (this) and $AnimationPlayer
	
	# ensure reference is set if automatic grab failed
	if not hub.anim_player:
		hub.anim_player = hub.get_node("AnimationPlayer")

	# 2. Build AI Brain (Resources)
	print("Building Test AI Brain for Modular Enemy...")
	
	# Create the Root Sequence: Move Right -> Idle -> Move Left -> Idle -> Repeat
	var seq = State_sequence.new()
	seq.state_name = "PatrolLoop"
	
	# State 1: Move Right
	var move_right = Enemy_move_state.new()
	move_right.state_name = "Right"
	move_right.speed = 150.0
	move_right.angle = 0.0 # 0 degrees = Right
	move_right.duration = 1.0
	move_right.move_type = "direction_linear"
	
	# State 2: Idle
	var idle1 = Enemy_idle_state.new()
	idle1.state_name = "Wait1"
	idle1.duration = 0.5
	
	# State 3: Move Left
	var move_left = Enemy_move_state.new()
	move_left.state_name = "Left"
	move_left.speed = 150.0
	move_left.angle = 180.0 # 180 degrees = Left
	move_left.duration = 1.0
	move_left.move_type = "direction_linear"

	# State 4: Idle
	var idle2 = Enemy_idle_state.new()
	idle2.state_name = "Wait2"
	idle2.duration = 0.5

	# Connect to Sequence
	# Explicitly creating typed array to avoid assignment errors
	var children: Array[State_object] = []
	children.append(move_right)
	children.append(idle1)
	children.append(move_left)
	children.append(idle2)
	seq.child_states = children
	
	# 3. Assign to Hub
	# set_up_root initializes the states
	hub.set_up_root(seq)
	
	print("AI Brain Ready. Root: ", hub.root_state.state_name)

	# 4. Initialize Base Controller
	super._ready()
	
	# 5. Manually Activate (Simulate spawning)
	# This ensures the scheduler and logic loops are active
	if not is_spawn:
		# We try-catch essentially by checking if logic exists
		# Basic activation to enable updates
		is_spawn = true
		_character.isActive = true
		# We don't call full activate() to avoid GameManager dependency crash in isolation
		print("Test Enemy Activated.")
