extends Node2D

@onready var enemy: Node2D = $"../Friendly_Battalion"

var cooldown := 1.0

func _enter_tree() -> void:
	for i in self.get_children():
		if i.faction_id != 1:
			i.faction_id = 1
		i.tilemap = $"../TileMapLayer"
