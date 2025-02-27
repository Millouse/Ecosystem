extends Node2D

var size = Vector2(100, 100)
var grid_size = 100

# 0 for dead, 1 for alive
var grid = []

# grid with neighbours
var neighbours = []

@onready var tilemap = $TileMapLayer

var alive_neighbours = 0
var rng = RandomNumberGenerator.new()

var spawned_creature_count: int = 0

func find_alive_neighbours(y: int, x: int, min_range: int, max_range: int):
	var number_of_alive_neighbours = 0
	for yp in range(min_range, max_range):
		for xp in range(min_range, max_range):
			var ny = y + yp
			var nx = x + xp
			if ny < 0 or ny >= size.y or nx < 0 or nx >= size.x:
				continue
			if grid[ny][nx] == 1:
				number_of_alive_neighbours += 1
	if grid[y][x] == 1:
		number_of_alive_neighbours -= 1
	if number_of_alive_neighbours < 0:
		number_of_alive_neighbours = 0
	return number_of_alive_neighbours

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("game_of_life_scene"):
		get_tree().change_scene_to_file("res://scenes/selector_scenes.tscn")

func _ready() -> void:
	reset()

func survive(y: int, x: int):
	if grid[y][x] == 1:
		if neighbours[y][x] < 2:
			return 0
		elif neighbours[y][x] > 3:
			return 0
		else:
			return 1
	elif grid[y][x] == 0:
		if neighbours[y][x] == 3:
			return 1
		else:
			return 0

func recolor(y: int, x: int):
	if grid[y][x] == 1:
		tilemap.set_cell(Vector2(x, y), 1, Vector2.ZERO)
	else:
		tilemap.set_cell(Vector2(x, y), 0, Vector2.ZERO)

func reset():
	grid = []
	neighbours = []
	spawned_creature_count = 0
	for y in range(size.y):
		grid.append([])
		neighbours.append([])
		for x in range(size.x):
			neighbours[y].append(0)
			if rng.randf_range(0.0, 1.0) < 0.3:
				grid[y].append(1)
			else:
				grid[y].append(0)
			recolor(y, x)

func _on_timer_timeout() -> void:
	for y in range(size.y):
		for x in range(size.x):
			alive_neighbours = find_alive_neighbours(y, x, -1, 2)
			neighbours[y][x] = alive_neighbours
	for y in range(size.y):
		for x in range(size.x):
			grid[y][x] = survive(y, x)
			var adult = find_alive_neighbours(y, x, -2, 3)
			if adult >= 18:
				spawned_creature_count += 1
			recolor(y, x)
