extends ColorRect

var weather_filters = [
	"res://assets/Shaders/Rain.gdshader",
	"res://assets/Shaders/Fog.gdshader",
	"res://assets/Shaders/God Rays.gdshader",
	"" 
]
func _ready():
	var picked_filter = weather_filters.pick_random()
	if picked_filter != "":
		material = ShaderMaterial.new()
		material.shader = load(picked_filter)
	else:
		material = null 
