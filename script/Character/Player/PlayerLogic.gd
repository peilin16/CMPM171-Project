extends Character_logic
class_name Player_logic;




func get_shoot_script(target:Vector2)->Array:
	var default_script =[
	{
		"action":"shoot",
		"type":"fan",
		"spread":20,
		"num":3,
	   "pool":"MEDIUM_ROUND_BULLET",
	   "aim":"TARGET",
		"target":target,
	   "speed":120,
	   "fiction":"player",
	   "color":"RED"
	 }
	]
	#code for base shoot setting
	return default_script;
