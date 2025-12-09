extends Node2D

@onready var line: Line2D = $Line2D

signal path_finished(points: Array[Vector2])

var path_points: Array[Vector2] = []
var drawing: bool = false
var select_unit: bool = false

var grid_size: Vector2 = Vector2(16, 16)

func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position().snapped(grid_size)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and Global.unit_selected == self.get_parent() and $"../Character/Outline".visible == true:
		if event.pressed:
			drawing = true
		else:
			drawing = false
			select_unit = false
			if path_points.is_empty() == false:
				emit_signal("path_finished", path_points)
				path_points.clear()
	if event is InputEventMouseMotion and drawing and select_unit and Global.inside_map:
		if path_points.is_empty() or (path_points[-1].distance_to(mouse_pos) > 0 and path_points[-1].distance_to(mouse_pos) <= 23):
			if path_points.is_empty() == false and path_points[-1].distance_to(get_global_mouse_position()) >= 9 and path_points[-1].distance_to(get_global_mouse_position()) <= 15:
				pass
			elif path_points.size() > 1 and path_points[-2].distance_to(mouse_pos) == 0:
				path_points.pop_back()
				line.remove_point(line.points.size()-1)
			else:
				path_points.append(mouse_pos)
				line.add_point(to_local(mouse_pos))
