# RumiaIdleState.gd
extends State_object
class_name Player_fire_state

var _was_called_this_frame: bool = false
var _original_shooting = null
var _has_played_animation: bool = false  # 标记动画是否已播放

func _init(hub: State_hub = null) -> void:
	state_name = "Fire"
	priority = 4
	can_be_interrupted = true
	state_animation = Animation_object.new()
	state_animation.animation_name = "fire"
	state_animation.is_loop = false

func on_ready(controller, hub: State_hub, anim: Animation_player) -> void:
	pass
	
	#_original_shooting = controller.player_shooting
	#
	#controller.player_shooting = func(payload):
		#_was_called_this_frame = true
		#if _original_shooting:
			#_original_shooting.call(payload)

func trigger(controller) -> bool:
	# 只在被调用的那一帧返回true
	if _was_called_this_frame:
		_was_called_this_frame = false  # 立即重置，确保只触发一次
		_has_played_animation = false   # 重置动画标记
		return true
	return false

func enter(controller, hub: State_hub, anim: Animation_player) -> void:
	anim.play(state_animation)
	_has_played_animation = true

func update(controller, hub: State_hub, anim: Animation_player, delta: float) -> void:
	controller.move(delta)
	
	# 如果在动画播放期间再次被调用，可以重新播放动画
	if _was_called_this_frame and _has_played_animation:
		anim.play(state_animation)  # 重新播放
		_was_called_this_frame = false  # 消费掉

func is_done(controller, hub: State_hub, anim: Animation_player) -> bool:
	return anim.is_finished()

func exit(controller, hub: State_hub, anim: Animation_player) -> void:
	_was_called_this_frame = false
	_has_played_animation = false
	# 不要恢复_original_shooting！
