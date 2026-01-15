extends Node2D

func _enter_tree() -> void:
	for i in self.get_children():
		if i.faction_id != 1:
			i.faction_id = 1
