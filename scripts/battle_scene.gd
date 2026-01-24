extends Node2D

@onready var map: TileMapLayer = $TileMapLayer
@onready var bg: TextureRect = $Background
@onready var f_bat: Node2D = $Friendly_Battalion
@onready var e_bat: Node2D = $Enemy_Battalion
var astar_grid: AStarGrid2D
var grid_size = 16

func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.cell_size = map.tile_set.tile_size
	astar_grid.region = map.get_used_rect()
	astar_grid.update()
	
	for id in map.get_used_cells():
		var data = map.get_cell_tile_data(id)
		if data and data.get_custom_data('obstacle'):
			astar_grid.set_point_solid(id)
		elif data and data.get_custom_data('path'):
			astar_grid.set_point_weight_scale(id, 0.5)
		elif data and data.get_custom_data('forest'):
			astar_grid.set_point_weight_scale(id, 2)
		else:
			astar_grid.set_point_weight_scale(id, 1)
	
	for i in f_bat.get_children():
		i.set_envirement(astar_grid, map, f_bat, e_bat)
	
	for i in e_bat.get_children():
		i.set_envirement(astar_grid, map, e_bat, f_bat)
