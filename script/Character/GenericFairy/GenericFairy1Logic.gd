extends enemy_logic
class_name Generic_fairy1_logic


func _init(_controller, _character: Character) -> void:
	controller = _controller;
	character = _character as Generic_fairy1;

func apply_behavior(code: String = "") -> void:
	if code != "":
		behavoir = code

	match behavoir:
		"_first_time_line_level1":
			character.max_hp = 10
			character.hp = character.max_hp
			_first_time_line_level1()
		"sniper_slow":
			character.max_hp = 20
			character.hp = character.max_hp
			_build_behavior_sniper_slow()
		"circle_fairy":
			character.max_hp = 5
			character.hp = character.max_hp
			_build_behavior_circle_fairy()
		
		_:
			# 默认行为：比如简单直线 + 不射击
			character.max_hp = 5
			character.hp = character.max_hp
			_build_behavior_default();
			
func _first_time_line_level1()->void:

	

	var script = [
		
		#{"action":"timer", "sec":0.1},
	  	{
			"action": "composite",
			"array":[
				{
					"action": "move",
					"type":"direction_linear",
					"speed":110,
					"angle":180,
			  	},

				{
					"action": "sequence",
					"array":[
						{
							"action":"timer", 
							"sec":3
						},
						{
							"action":"cast",
							"type":"multi",
						   "pool":"MEDIUM_ROUND_BULLET",
						   "aim":"OBJECT",
						   "speed":200,
						   "interval":0.3,
						   "num":4,
						   "color":"BLUE",
						   "vfx":[
								{"shoot mode":"start","mode":"shoot", "name":"MuzzleFlash1", "life":2, "front":true,"follow":true},
								]
			  			}
					]
				}
			]
		}
				
				

	]	
	scheduler.setup(script);
	scheduler.start();
	

func _build_behavior_grunt_straight() -> void:
	var move_cfg := Move_configure.new()
	move_cfg._simple_configure_for_direction(controller.get_actor_position(), 120.0, 90.0)
	var move_pattern := Linear_move_pattern.new()

	var move_order := Order.new()
	move_order.system_configure = move_cfg
	move_order.system_pattern = move_pattern
	move_order.duration = 3.0
	queue.append(move_order)

	var shoot_cfg := Shoot_configure.new()
	# shoot_cfg.xxx …
	var shoot_pattern := Shooting_pattern.new()
	var shoot_order := Order.new()
	shoot_order.system_configure = shoot_cfg
	shoot_order.system_pattern = shoot_pattern
	shoot_order.duration = 2.0
	queue.append(shoot_order);
	

func _build_behavior_sniper_slow() -> void:
	pass


func _build_behavior_circle_fairy() -> void:
	# 例如：调用 Arc_pattern + Orbital_revolution_pattern
	pass



func _build_behavior_default()->void:
	var script = [
		{"action":"timer", "sec":0.2},
	  	{
			"action":"cast",
			"type":"random_fan",
		   "pool":"MEDIUM_ROUND_BULLET",
		   "aim":"OBJECT",
		   "speed":200,
		   "spread":23,
		   "count":4,
		   "time":4,
		   "interval":0.4,
		   "color":"BLUE",
		   "color_seed":2,
		   "vfx":[
				{"mode":"start", "name":"MuzzleFlash1", "life":0.15, "front":true},
				]
		  },
		{"action":"timer", "sec":3.0},

		  {
			"action":"cast",
			"type":"single",
		   "aim":"TARGET",
		   "target": Vector2(-200, 200),
		   "pool":"MEDIUM_ROUND_BULLET",
		   "speed":350,
		   "color":"RED"
		  },
		]	
	scheduler.setup(script);
	scheduler.start();
