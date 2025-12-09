extends Area2D

@onready var line: Line2D = $"../PathDraw/Line2D"
@export var move_time: float = 0.5

var path: Array[Vector2] = []
var is_moving: bool = false

func set_path(new_path: Array[Vector2]) -> void:
	if is_moving:
		return
	path = new_path.duplicate()
	if path.size() > 0:
		global_position = path[0]
		path.pop_front()
	if path.size() > 0:
		_start_moving()

func _start_moving() -> void:
	is_moving = true
	move_along_path()

func move_along_path() -> void:
	if path.is_empty():
		is_moving = false
		line.clear_points()
		return
	var next_tile = path.pop_front()
	var start_pos := global_position
	var t := 0.0
	var duration := move_time
	while t < 1.0:
		if t >= 0.5 - (0.5*(get_physics_process_delta_time() / duration)) and t <= 0.5 + (0.5*(get_physics_process_delta_time() / duration)):
			line.remove_point(0)
		t += get_physics_process_delta_time() / duration
		global_position = start_pos.lerp(next_tile, t)
		await get_tree().process_frame
	global_position = next_tile
	move_along_path()
