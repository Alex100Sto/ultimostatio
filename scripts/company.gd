extends Node2D

class_name Company

@export var data: CompanyData
@export var faction_id: int

var health: float

@onready var formation: Area2D = $Formation
@onready var outline: Sprite2D = $Formation/Outline
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var line: Line2D = $Line2D
@export var color: Color

var map: AStarGrid2D 
var select_bat = false
var moving = false
var grid := Vector2(16,16)
var grid_size = 16

func _ready() -> void:
	if !faction_id:
		$Formation/Sprite2D.texture = load("res://assets/armies/ally_company.png")
	else:
		$Formation/Sprite2D.texture = load("res://assets/armies/enemy_company.png")
	health = data.center_hp_max
	line.modulate = color
	formation.connect("moved", Callable(self, "_on_formation_moved"))

func _on_formation_mouse_entered() -> void:
	select_bat = true

func _on_formation_mouse_exited() -> void:
	select_bat = false

func _on_formation_moved(move: bool) -> void:
	moving = move

func set_map(_map: AStarGrid2D):
	map = _map

func _unhandled_input(event: InputEvent) -> void:
	if outline.visible and moving == false:
		line.points = map.get_point_path(formation.global_position/grid, get_global_mouse_position().snapped(grid)/grid)
		for i in line.points.size():
			line.points[i] = line.to_local(line.points[i])
	if Input.is_action_just_pressed("select"):
		if select_bat == true:
			Global.company_selected.append(self)
			outline.visible = true
		else:
			Global.company_selected.erase(self)
			outline.visible = false
			line.clear_points()
	if outline.visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		var weights: Array[float] = []
		for point in map.get_point_path(formation.global_position/grid, get_global_mouse_position().snapped(grid)/grid):
			weights.append(map.get_point_weight_scale(point/grid))
		formation.set_path(map.get_point_path(formation.global_position/grid, get_global_mouse_position().snapped(grid)/grid), weights)
		moving = true
