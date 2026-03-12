extends Level_controller
class_name Level2_controller





func _ready() -> void:
	GameManager.level_manager.setup(self);
	super._ready();
	await ToolBar.globalDelayCall.delay(0.3)
	shop_menu.visible = false;
	await get_tree().process_frame
	name = "Forest";
	SoundManager.command({
		"sound":"bgm",
		"command":"start",
		"name":"BGM3",
		"fade_in":0.2,
		"fade_out":0.7,
		"transfer_fade_out":0.2,
		"use_loop_segment":true,
		"loop_start_sec":0.3,
		"loop_end_sec":18.0,
		"volume_mul":0.4,
		"pitch_scale":1.0
	});
	start_game();
	level = Level2.new();
func start_game()->void:
	super.start_game();
