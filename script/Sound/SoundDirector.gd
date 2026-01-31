extends Node2D
class_name Sound_director

var bgm_manager = SoundManager.bgm_manager;
var current_bgm;
func play(id: String) -> void:
	bgm_manager.play_bgm(id)

func stop_loop_and_finish() -> void:
	bgm_manager.stop_loop_and_finish();
