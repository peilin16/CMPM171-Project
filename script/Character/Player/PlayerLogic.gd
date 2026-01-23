extends Character_logic
class_name Player_logic;




func get_shoot_script(target:Vector2)->Array:
	var default_script =[
	{"type":"single",
	   "pool":"MEDIUM_ROUND_BULLET",
	   "aim":"TARGET",
		"target":target,
	   "speed":270,
	   "fiction":"player",
	   "color":"BLUE"
	 }
	]
	#code for base shoot setting
	return default_script;
