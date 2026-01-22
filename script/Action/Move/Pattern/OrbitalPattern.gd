extends Move_pattern
class_name Orbital_revolution_pattern


var cfg: Orbital_revolution_configure
var angle_rad: float = 0.0
var traveled_angle: float = 0.0   # total absolute angle moved (in radians)

func _init() -> void:
	belong = System.Belong.MOVE


# Called once before first play()
func _ready(runner: Runner, configure: Configure) -> void:
	cfg = configure as Orbital_revolution_configure
	if cfg == null:
		return

	var move_runner := runner as Move_runner
	if move_runner == null or move_runner.controller == null:
		return

	# Ensure center is valid. If not set, use current position as center.
	if cfg.center == Vector2.ZERO:
		cfg.center = move_runner.controller.get_actor_position()

	# Compute initial angle from center to actor position.
	var pos = move_runner.controller.get_actor_position()
	var offset = pos - cfg.center

	if offset.length() > 0.0:
		angle_rad = offset.angle()
	else:
		# If actor is exactly at center, place it on the +X axis.
		angle_rad = 0.0
		var radius_x := cfg.radius
		var radius_y := cfg.radius * (1.0 - cfg.ellipticity)
		move_runner.controller.set_actor_position(
			cfg.center + Vector2(radius_x, 0.0)
		)
	
	traveled_angle = 0.0
	runner.is_ready = true;

# Main loop: returns true if still rotating, false if finished.
func play(runner: Runner, configure: Configure, delta: float) -> bool:
	#if cfg == null:
		#return false

	var move_runner := runner as Move_runner
	#if move_runner == null or move_runner.controller == null:
		#return true

	# 1. Compute angular speed in radians per second.
	var omega_rad := deg_to_rad(cfg.angular_speed_deg)

	# 2. Update angle.
	var delta_angle := omega_rad * delta
	angle_rad += delta_angle
	traveled_angle += abs(delta_angle)

	# 3. Compute ellipse radii.
	var radius_x := cfg.radius
	var radius_y := cfg.radius * (1.0 - cfg.ellipticity)
	if radius_y < 0.0:
		radius_y = 0.0

	# 4. Compute new position on the ellipse.
	var rot := deg_to_rad(cfg.ellipse_rotation_deg)
	var cos_r := cos(rot)
	var sin_r := sin(rot)

	# original axis-aligned ellipse point
	var px := cos(angle_rad) * radius_x
	var py := sin(angle_rad) * radius_y

	# rotated ellipse
	var rx := px * cos_r - py * sin_r
	var ry := px * sin_r + py * cos_r

	var new_pos := cfg.center + Vector2(rx, ry)
	
	move_runner.controller.set_actor_position(new_pos)

	# 5. Infinite rotation mode: never finishes, caller must interrupt.
	if cfg.is_infinite:
		return false

	# 6. Check how many rounds (full circles) we have completed.
	var rounds_done := traveled_angle / TAU  # TAU = 2 * PI

	if rounds_done >= float(cfg.round):
		# Snap to final position on the orbit (optional).
		return true  # finished

	return false
