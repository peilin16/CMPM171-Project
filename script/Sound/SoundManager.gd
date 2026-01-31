# Sound_manager.gd
extends Node
class_name Sound_manager

enum BUS { MASTER, SFX, BGM }

@onready var sfx_manager: SFX_manager = $SFX
@onready var bgm_manager: BGM_manager = $BGM

var sfx_parser:SFX_parser = SFX_parser.new();


#main entrance
func command(cmd: Dictionary) -> void:
	var t := str(cmd.get("sound", "sfx"))
	match t:
		"sfx":
			sfx_manager.play_sound(cmd)
		"bgm":
			# bgm_manager.play_sound(cmd)  # 后续再做
			pass


func stop_bgm_loop_and_finish() -> void:
	bgm_manager.stop_loop_and_finish()

func stop_bgm() -> void:
	bgm_manager.stop_bgm()

func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, volume_db)
