# Animation_player.gd
extends Node2D
class_name Animation_player

@export var sprite: AnimatedSprite2D
var current_animation: Animation_object
var playing:bool = false

func play(animation: Animation_object) -> void:
	if sprite == null :
		return
	sprite.stop();
	current_animation = animation
	sprite.speed_scale = animation.animation_speed
	playing = true;
	# 设置循环模式
	if sprite.sprite_frames:
		var animation_loop = sprite.sprite_frames.get_animation_loop(animation.animation_name)
		# 如果当前循环模式与需要的不一致，则设置新的循环模式
		if animation_loop != animation.is_loop:
			sprite.sprite_frames.set_animation_loop(animation.animation_name, animation.is_loop)
	
	sprite.play(animation.animation_name)
	
	# 连接动画完成信号
	if not animation.is_loop:
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)
	else:
		# 如果是循环动画，断开连接
		if sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.disconnect(_on_animation_finished)

func anima_hide()->void:
	sprite.visible =false;
	
func anima_display()->void:
	sprite.visible =true;

func _on_animation_finished() -> bool:
	# 非循环动画完成时的处理
	print("Animation finished: ", current_animation.animation_name if current_animation else "")
	playing = false;
	return playing;


func is_finished() -> bool:
	if sprite == null:
		return true
	return not sprite.is_playing()
