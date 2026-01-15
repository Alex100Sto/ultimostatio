class_name Health
extends CompanyData

@export var max_hp_centre: float
var current_hp: float

func _ready() -> void:
	current_hp = max_hp_centre
