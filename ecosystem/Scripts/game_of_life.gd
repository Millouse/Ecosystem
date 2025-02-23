extends Node3D

signal add_pop

var size = Vector2(100, 100)
var grid_size = 100

# 0 for dead, 1 for alive
var grid = []

var cubes = []

# grid with neighbours
var neighbours = []

@onready var camera = $"../Camera3D"
@onready var cube_scene = %Cube
@onready var creature = %Creature

var alive_neighbours = 0
var rng = RandomNumberGenerator.new()

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
	camera.position = Vector3(grid_size * 0.5, grid_size * 0.8, grid_size * 1.2)
	camera.look_at(Vector3(grid_size * 0.5, 0, grid_size * 0.5))
	for y in range(size.y):
		grid.append([])
		neighbours.append([])
		cubes.append([])
		for x in range(size.x):
			neighbours[y].append(0)
			if rng.randf_range(0.0, 1.0) < 0.3:
				grid[y].append(1)
			else:
				grid[y].append(0)
			var cube_instance = cube_scene.duplicate()
			add_child(cube_instance)
			cube_instance.position = Vector3(x * 1.1, 0, y * 1.1)
			var mat = cube_instance.get_surface_override_material(0)
			mat = mat.duplicate()
			cube_instance.set_surface_override_material(0, mat)
			cubes[y].append(cube_instance)
			recolor(y, x)

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
		cubes[y][x].get_surface_override_material(0).albedo_color = Color(1, 1, 1)
	else:
		cubes[y][x].get_surface_override_material(0).albedo_color = Color(0, 0, 0)

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
				## Spawn creature (matteo)
				add_pop.emit()
				var creature_instance = creature.duplicate()
				add_child(creature_instance)
				creature_instance.position = Vector3(x * 1.1, 0, y * 1.1)
			recolor(y, x)
