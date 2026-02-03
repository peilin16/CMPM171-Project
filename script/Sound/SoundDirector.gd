extends Node2D
class_name Sound_director

var current_bgm;


func execute(cmd: Dictionary) -> void:
	# just forward
	SoundManager.command(cmd.get("command",cmd.get("play","")));
