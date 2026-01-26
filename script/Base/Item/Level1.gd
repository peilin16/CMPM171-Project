extends Level
class_name Level1

#Level
#- BackgroundLayer     (z_index = 0)
#- EnemyBackLayer      (z_index = 100)
#- EnemyLayer          (z_index = 200)
#- PlayerLayer         (z_index = 300)
#- BulletLayer         (z_index = 400)
#- VFXBackLayer        (z_index = 450)
#- VFXFrontLayer       (z_index = 650)
#- UILayer (CanvasLayer)
func _init() -> void:
	level_name = "test_level"
	bullet_order = {
		"MEDIUM_ROUND_BULLET": 20
	}
	enemy_order = {
		"generic_fiary1": 4,
	}
	vfx_order = {
		"generic_fiary1": 4,
	}
func _end() -> void:
	pass
