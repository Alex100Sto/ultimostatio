extends Node2D


func _ready() -> void:
	pass

func _on_background_mouse_entered() -> void:
	Global.inside_map = true

func _on_background_mouse_exited() -> void:
	Global.inside_map = false
