extends Level_controller
class_name Level3_controller

@onready var weather_filter = $WeatherFilter

func _ready() -> void:
	
	super._ready();
	level = Level3.new();
	GameManager.level_manager.setup(self);
	await ToolBar.globalDelayCall.delay(0.3);
	shop_menu.visible = false;
	await get_tree().process_frame
	name = "Quay";
	SoundManager.command({
		"sound":"bgm",
		"command":"start",
		"name":"BGM2",
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
func start_game()->void:
	super.start_game();
	if weather_filter:
		var color_rect = weather_filter.get_node_or_null("ColorRect")
		if color_rect and color_rect.has_method("apply_weather"):
			color_rect.apply_weather()
