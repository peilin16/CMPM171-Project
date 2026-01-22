extends Move_configure
class_name Orbital_revolution_configure

# Use velocity mode later (for now we focus on constant-speed curve)

@export var is_infinite: bool = false
@export var radius: float = 10;
@export var center: Vector2;

@export var round:int = 1;
@export var angular_speed_deg: float = 90.0

@export var ellipse_rotation_deg:float = 0;
@export var ellipticity: float = 0.6;

#enum  Ellipticity: float = 0.6;
#@export var ellipticity:  = 0.6;
func default_pattern() ->Pattern:
	return Orbital_revolution_pattern.new();
