extends Wave_director
class_name Level1_wave_director




func config_waves() -> void:
	var config = [
		{
			"mode":"timer",
			"delay":1,
		},
		{
			"mode":"enemy_spawn",
			"type":"group",
			"name":"StoneLionBoss",
			"count":1,
			"behavior":"---",
			"positions":[3],
					
		},
		{
			"mode":"clear",
		},
		
		{
			"mode":"shop"
		},
		{
			"mode":"enemy_spawn",
			"type":"group",
			"name":"GruntPlus",
			"count":5,
			"behavior":"---",
			"positions":[0,1,2,3,4],
					
		},
		{
			"mode":"timer",
			"delay":12,
		},
		{
			"mode":"enemy_spawn",
			"type":"group",
			"name":"Grunt",
			"count":13,
			"behavior":"---",
			"positions":[0,1,2,3,4],
					
		},
		{
			"mode":"clear",
		},
		
		{
			"mode":"enemy_spawn",
			"name":"GruntPlus",
			"count":4,
			"behavior":"---",
			"positions":[2,3,4],
		},
		{
			"mode":"timer",
			"delay":7,
		},
		{
			"mode":"enemy_spawn",
			"type":"group",
			"name":"Grunt",
			"count":13,
			"behavior":"---",
			"positions":[0,1,2,3,4],
					
		},
		{
			"mode":"enemy_spawn",
			"type":"group",
			"name":"StoneLionBoss",
			"count":1,
			"behavior":"---",
			"positions":[3],
		},
		{
			"mode":"shop"
		}
		#{
			#"mode":"timer",
			#"delay":9,
		#}
		#
		#
	]
	create_wave_from_config(config)
