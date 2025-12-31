extends Node2D

@onready var character: Area2D = $Character
@onready var path_draw: Node2D = $PathDraw
@export var color: Color

func _ready() -> void:
	$PathDraw/Line2D.modulate = color
	path_draw.connect("path_finished", Callable(self, "_on_path_finished"))

func _on_path_finished(points: Array[Vector2]) -> void:
	character.set_path(points)

func _on_character_mouse_entered() -> void:
	path_draw.select_unit = true

func _on_character_mouse_exited() -> void:
	if path_draw.drawing == false:
		path_draw.select_unit = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		if path_draw.select_unit == true:
			Global.unit_selected = self
			$Character/Outline.visible = true
		else:
			$Character/Outline.visible = false
