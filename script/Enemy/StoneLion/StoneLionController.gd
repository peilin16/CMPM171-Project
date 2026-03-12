extends Enemy_controller
class_name StoneLionController

@onready var state_hub: State_hub = $StateHub
@onready var sprite: AnimatedSprite2D = $Sprite2D

var slam_cooldown: float = 0.0
var flame_cooldown: float = 0.0
var recover_timer: float = 0.0
var _hit_cooldown_timer: float = 0.0

func _init() -> void:
	name = "StoneLionBoss"
	enemy_type_name = "StoneLionBoss"
	_character = StoneLion.new()
	_logic = enemy_logic.new(self, _character)
	team = TEAM.ENEMY

func _ready() -> void:
	super._ready()
	set_visual_state("idle")

func set_visual_state(state_name: String) -> void:
	if sprite == null:
		return
	if sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(state_name):
		return
	if sprite.animation == state_name and sprite.is_playing():
		return
	sprite.play(state_name)

func _physics_process(delta: float) -> void:
	slam_cooldown = max(0.0, slam_cooldown - delta)
	flame_cooldown = max(0.0, flame_cooldown - delta)
	recover_timer = max(0.0, recover_timer - delta)
	_hit_cooldown_timer = max(0.0, _hit_cooldown_timer - delta)
	super._physics_process(delta)
	rotation = 0.0

func activate(behavoir_code: String = "", sprite_code: int = 0) -> void:
	var selector = State_selector.new()
	selector.state_name = "StoneLionSelector"

	var recover_state = StoneLionRecoverState.new()
	recover_state.priority = 40
	selector.child_states.append(recover_state)

	var slam_state = StoneLionJumpSlamState.new()
	slam_state.priority = 20
	selector.child_states.append(slam_state)

	var flame_state = StoneLionFlameFanState.new()
	flame_state.priority = 30
	selector.child_states.append(flame_state)

	var move_state = StoneLionMoveState.new()
	move_state.priority = 10
	selector.child_states.append(move_state)
	selector.default_state = move_state

	state_hub.set_up_root(selector)

	slam_cooldown = float(stats.get("slam_cooldown_initial", 0.6))
	flame_cooldown = float(stats.get("flame_cooldown_initial", 1.2))
	recover_timer = 0.0
	_hit_cooldown_timer = 0.0

	super.activate(behavoir_code)

func _can_take_hit() -> bool:
	if _hit_cooldown_timer > 0.0:
		return false
	_hit_cooldown_timer = float(stats.get("hit_cooldown", 0.1))
	return true

func behit(bullet: Bullet):
	if is_death:
		return
	if bullet == null or bullet.damage <= 0:
		return
	if not _can_take_hit():
		return
	super.behit(bullet)

func apply_hit_by_float(damage: float):
	if is_death:
		return
	if damage <= 0.0:
		return
	if not _can_take_hit():
		return
	super.apply_hit_by_float(damage)

func has_player() -> bool:
	return GameManager.player_manager and GameManager.player_manager.player != null

func _get_target_node() -> Node2D:
	if has_player():
		return GameManager.player_manager.player
	return null

func get_player_position_or(fallback: Vector2) -> Vector2:
	var target = _get_target_node()
	if target != null:
		if target.has_method("get_actor_position"):
			return target.get_actor_position()
		return target.global_position
	return fallback

func get_player_distance() -> float:
	var target = _get_target_node()
	if target == null:
		return INF
	if target.has_method("get_actor_position"):
		return global_position.distance_to(target.get_actor_position())
	return global_position.distance_to(target.global_position)

func should_use_jump_slam() -> bool:
	if recover_timer > 0.0:
		return false
	if slam_cooldown > 0.0:
		return false
	if not has_player():
		return false
	return true

func should_use_flame_fan() -> bool:
	if recover_timer > 0.0:
		return false
	if flame_cooldown > 0.0:
		return false
	if not has_player():
		return false
	return true

func request_flame_fan() -> void:
	var cast_script = [
		{
			"action": "cast",
			"type": "fan_shape",
			"aim": "OBJECT",
			"object": _get_target_node(),
			"faction": Bullet.Faction.ENEMY,
			"pool": str(stats.get("flame_pool", "MEDIUM_ROUND_BULLET")),
			"color": str(stats.get("flame_color", "RED")),
			"damage": int(stats.get("flame_damage", 10)),
			"speed": float(stats.get("flame_speed", 190.0)),
			"spread": float(stats.get("flame_spread", 42.0)),
			"count": int(stats.get("flame_count", 9)),
			"time": int(stats.get("flame_times", 3)),
			"interval": float(stats.get("flame_interval", 0.35))
		}
	]
	scheduler.preemption(cast_script)

func _get_sprite_bottom_offset() -> float:
	var fallback: float = float(stats.get("slam_vfx_bottom_offset", 18.0))
	if sprite == null:
		return fallback
	if sprite.sprite_frames == null:
		return fallback
	var anim_name: StringName = sprite.animation
	if anim_name == &"" or not sprite.sprite_frames.has_animation(anim_name):
		return fallback
	var frame_count: int = sprite.sprite_frames.get_frame_count(anim_name)
	if frame_count <= 0:
		return fallback
	var frame_idx: int = clampi(sprite.frame, 0, frame_count - 1)
	var frame_tex: Texture2D = sprite.sprite_frames.get_frame_texture(anim_name, frame_idx)
	if frame_tex == null:
		return fallback
	var half_height: float = frame_tex.get_size().y * absf(sprite.scale.y) * 0.5
	return max(half_height, fallback)

func play_slam_vfx(at_position: Vector2) -> void:
	if vfx_parser:
		var spawn_pos: Vector2 = at_position + Vector2(0.0, _get_sprite_bottom_offset())
		vfx_parser.setup({
			"name": str(stats.get("slam_vfx", "Explosion2")),
			"position": spawn_pos,
			"life": float(stats.get("slam_vfx_life", 0.9)),
			"speed": float(stats.get("slam_vfx_speed", 1.5)),
			"scale": float(stats.get("slam_vfx_scale", 1.35)),
			"amount": int(stats.get("slam_vfx_amount", 36)),
			"front": false
		})

func do_slam_impact() -> void:
	var slam_radius = float(stats.get("slam_radius", 100.0))
	var slam_damage = float(stats.get("slam_damage", 16.0))

	var target = _get_target_node()
	if target != null and target.global_position.distance_to(global_position) <= slam_radius:
		if target is Player_controller:
			var player = target as Player_controller
			var hurtbox := player.hurtbox as Hurt_box
			if hurtbox != null:
				hurtbox.hurt(slam_damage)
