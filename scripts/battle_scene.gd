extends Node2D

@onready var map: TileMapLayer = $TileMapLayer
@onready var bg: TextureRect = $Background
var astar_grid: AStarGrid2D
var grid_size = 16

func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar_grid.cell_size = map.tile_set.tile_size
	astar_grid.region = Rect2((bg.position.x + grid_size) / grid_size, (bg.position.y + grid_size) / grid_size, bg.size.x / grid_size, bg.size.y / grid_size)
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
	
	$Battalion/Company.set_map(astar_grid)
	$Battalion/Company2.set_map(astar_grid)
	$Battalion/Company3.set_map(astar_grid)
