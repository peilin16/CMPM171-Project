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
			"name":"Grunt",
			"count":2,
			"behavior":"---",
			"positions":[0,1],
					
		},
		#{
			#"mode":"timer",
			#"delay":6,
		#},
		#{
			#"mode":"enemy_spawn",
			#"type":"group",
			#"name":"Fairy1Group",
			#"interval":1,
			#"behavior":"top_line_move_level1",
			#"members":[
				#{
					#"template":"",
					#"name":"GENERIC_FAIRY_1",
					#"num":8,
					#"ac":[32,40],
					#"dc":[32,40],
					#"textures":[0,3],
					#"positions":[Vector2(900,-200)]
				#}
			#]			
		#},
		
		
		
		#{
			#"mode":"timer",
			#"delay":9,
		#}
		#
		#
	]
	create_wave_from_config(config)
