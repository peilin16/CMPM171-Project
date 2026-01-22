extends Bullet
class_name medium_round_bullet




func _init() -> void:
	super._init();
	damage = 10;
	pool_name = "MEDIUM_ROUND_BULLET"; # new value
	
func _update_texture(state):
	match state:
		BulletColor.BLUE:
			return load("res://assets/bullet/RoundBullet/blueMediumRoundBullet.png")
		BulletColor.RED:
			return load("res://assets/bullet/RoundBullet/redMediumRoundBullet.png")
		BulletColor.GREEN:
			return load("res://assets/bullet/RoundBullet/greenMediumRoundBullet.png");
