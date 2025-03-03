extends Node2D

var size := Vector2(100, 100)
var grid_size := int(size.x * size.y)
var moore_neighbors := []
var adult_neighbors := []

var grid_a := PackedInt32Array()
var grid_b := PackedInt32Array()
var current_grid: PackedInt32Array
var next_grid: PackedInt32Array
var changed_cells := []
var spawned_creature_count := 0

@onready var tilemap = $TileMapLayer

func _ready() -> void:
	var unique_seed = get_instance_id()  # Unique seed for each gol
	seed(unique_seed)  # Set the random seed for this gol
	
	# Precompute neighbor indices for each cell
	moore_neighbors.resize(grid_size)
	adult_neighbors.resize(grid_size)
	var width = int(size.x)
	for i in grid_size:
		var x = i % width
		var y = i / width
		
		# Moore neighbors (3x3)
		var moore = []
		for dy in [-1, 0, 1]:
			for dx in [-1, 0, 1]:
				if dy == 0 and dx == 0:
					continue
				var nx = x + dx
				var ny = y + dy
				if nx >= 0 && nx < width && ny >= 0 && ny < int(size.y):
					moore.append(ny * width + nx)
		moore_neighbors[i] = moore
		
		# Adult neighbors (5x5)
		var adult = []
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				if dy == 0 and dx == 0:
					continue
				var nx = x + dx
				var ny = y + dy
				if nx >= 0 && nx < width && ny >= 0 && ny < int(size.y):
					adult.append(ny * width + nx)
		adult_neighbors[i] = adult
	
	reset()

func reset() -> void:
	grid_a.resize(grid_size)
	grid_b.resize(grid_size)
	current_grid = grid_a
	next_grid = grid_b
	spawned_creature_count = 0
	
	for i in grid_size:
		current_grid[i] = 1 if randf() < 0.3 else 0
	
	update_entire_tilemap()

func update_entire_tilemap() -> void:
	var width = int(size.x)
	for i in grid_size:
		var x = i % width
		var y = i / width
		tilemap.set_cell(Vector2(x, y), current_grid[i], Vector2.ZERO)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("game_of_life_scene"):
		get_tree().change_scene_to_file("res://scenes/selector_scenes.tscn")

func _on_timer_timeout() -> void:
	changed_cells.clear()
	var width = int(size.x)
	
	for i in grid_size:
		var current_state = current_grid[i]
		
		# Count Moore neighbors
		var moore_count = 0
		for j in moore_neighbors[i]:
			moore_count += current_grid[j]
		
		# Calculate next state
		var next_state = 0
		if current_state == 1:
			next_state = 1 if (moore_count == 2 || moore_count == 3) else 0
			# Count adult neighbors only if alive
			var adult_count = 0
			for j in adult_neighbors[i]:
				adult_count += current_grid[j]
			if adult_count >= 20:
				spawned_creature_count += 1
		else:
			next_state = 1 if (moore_count == 3) else 0
		
		# Track changes
		if next_state != current_state:
			changed_cells.append(i)
		
		next_grid[i] = next_state
	
	# Swap grids
	var temp = current_grid
	current_grid = next_grid
	next_grid = temp
	
	# Update tilemap
	for idx in changed_cells:
		var x = idx % width
		var y = idx / width
		tilemap.set_cell(Vector2(x, y), current_grid[idx], Vector2.ZERO)
