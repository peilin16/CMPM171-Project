extends Node
class_name Distance_measure


# Pattern helper functions
func angle_deg_to_dir(angle_deg: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(angle_deg)).normalized()

func dir_to_angle_deg(dire: Vector2) -> float:
	return rad_to_deg(dire.angle())

func normalize_angle(angle_deg: float) -> float:
	return fposmod(angle_deg, 360.0)
