extends Node
class_name Tool_bar


@onready var gameIDGenerator: Game_Id_generator = $GameIDGenerator
@onready var distanceMeasure: Distance_measure = $DistanceMeasure
@onready var repeatableRandomGenerator: Repeatable_random_generator = $RepeatableRandomGenerator
@onready var globalDelayCall: Global_delay_call = $GlobalDelayCall
@onready var predicting_move:Predicting_move = $PredictingMove
func _ready():
	print("Tool bar ready.")
