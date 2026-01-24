extends Node2D

class_name Company

@export var data: CompanyData
@export var faction_id: int

var health: float
var attack_dmg: float
var attack_rng: float
var attack_cdw: float

var cooldown: float = 0.0

var occupied_space: Vector2

@onready var formation: Area2D = $Formation
@onready var sprite: Sprite2D = $Formation/Sprite2D
@onready var outline: Sprite2D = $Formation/Outline
@onready var health_bar: TextureProgressBar = $Formation/HealthBar
@onready var line: Line2D = $Node/Line2D
@export var color: Color

var tilemap: TileMapLayer
var map: AStarGrid2D 
var enemies: Node2D
var allies: Node2D
var select_bat = false
var moving = false
var grid := Vector2(16,16)
var sprite_check: bool = false

func _ready() -> void:
	if !faction_id:
		sprite.texture = load("res://assets/armies/ally_company.png")
	else:
		sprite.texture = load("res://assets/armies/enemy_company.png")
	health = data.center_hp_max
	attack_dmg = data.attack_damage
	attack_rng = data.attack_range
	attack_cdw = data.attack_cooldown
	occupied_space = global_position
	line.modulate = color
	formation.connect("moved", Callable(self, "_on_formation_moved"))

func _on_formation_mouse_entered() -> void:
	select_bat = true

func _on_formation_mouse_exited() -> void:
	select_bat = false

func _on_formation_moved(move: bool) -> void:
	moving = move

func set_envirement(_map: AStarGrid2D, _tilemap: TileMapLayer, _ally: Node2D, _enemy: Node2D):
	map = _map
	tilemap = _tilemap
	allies = _ally
	enemies = _enemy

func _physics_process(delta: float) -> void:
	cooldown -= delta
	
	if cooldown <= 0:
		try_attack()

func try_attack():
	var curr_cell := tilemap.local_to_map(to_local(global_position))
	
	var closest_target: Node2D = null
	var closest_dist := INF
	
	for enemy in enemies.get_children():
		if closest_target:
			break
		var enemy_cell := tilemap.local_to_map(enemy.to_local(global_position))
		var dist := (curr_cell - enemy_cell).length()
		
		if dist <= 0 and faction_id > 0 and !sprite_check:
			same_tile_combat_enter()
			sprite_check = true
		elif dist > 0 and faction_id > 0 and sprite_check:
			same_tile_combat_exit()
			sprite_check = false
		
		if dist <= attack_rng and dist < closest_dist:
			closest_dist = dist
			closest_target = enemy
	
	if closest_target:
		attack(closest_target)

func same_tile_combat_enter():
	sprite.scale.x = -1
	sprite.modulate = Color(1, 1, 1, 0.5)
	health_bar.position += Vector2(13, 0)

func same_tile_combat_exit():
	sprite.scale.x = 1
	sprite.modulate = Color(1, 1, 1, 1)
	health_bar.position += Vector2(-13, 0)

func attack(target: Node2D):
	cooldown = attack_cdw
	target.take_damage(attack_dmg)

func take_damage(amount: float):
	health -= amount
	health_bar.value = health
	if health <= 0:
		die()

func die():
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if faction_id > 0:
		return
	if outline.visible and moving == false:
		line.points = map.get_point_path(formation.global_position/grid, get_global_mouse_position().snapped(grid)/grid)
		for i in line.points.size():
			line.points[i] = line.to_local(line.points[i])
	if Input.is_action_just_pressed("select"):
		if select_bat == true and moving == false:
			outline.visible = true
		else:
			outline.visible = false
			line.clear_points()
	if outline.visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and moving == false:
		for ally in allies.get_children():
			if ally.occupied_space == get_global_mouse_position().snapped(grid):
				return
		occupied_space = get_global_mouse_position().snapped(grid)
		var weights: Array[float] = []
		for point in map.get_point_path(formation.global_position/grid, get_global_mouse_position().snapped(grid)/grid):
			weights.append(map.get_point_weight_scale(point/grid))
		formation.set_path(map.get_point_path(formation.global_position/grid, get_global_mouse_position().snapped(grid)/grid), weights)
		moving = true
