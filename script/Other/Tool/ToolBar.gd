extends Node
class_name Tool_bar


@onready var gameIDGenerator: Node = $GameIDGenerator
@onready var distanceMeasure: Node = $DistanceMeasure
@onready var repeatableRandomGenerator: Node = $RepeatableRandomGenerator
@onready var globalDelayCall: Node = $GlobalDelayCall
func _ready():
	print("Tool bar ready.")
