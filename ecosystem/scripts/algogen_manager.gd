extends Node3D

# Selection method
enum SelectionMethod { TOURNAMENT, ROULETTE }
@export var selection_method: SelectionMethod = SelectionMethod.ROULETTE
@export var team: int

# Population settings
const POPULATION_SIZE = 5
const GENERATION_DURATION = 150

# Scene references
@export var creature_scene: PackedScene
@export var tree: Node
@export var base: Node

# Population tracking
var current_population = []
var generation = 1
var generation_timer = 0.0
var best_fitness = 0.0

func _ready():
	create_initial_population()

func _process(delta):
	generation_timer += delta
	# We'll probably do something else for generation evolving
	if generation_timer >= GENERATION_DURATION:
		evaluate_and_evolve()
		generation_timer = 0.0

func create_initial_population():
	for i in range(POPULATION_SIZE):
		spawn_creature()
	print("Generation 1 created!")

func spawn_creature():
	var creature: Creature = creature_scene.instantiate()
	creature.global_position = global_position
	creature.tree = tree
	creature.base = base
	creature.team = team
	add_child(creature)
	current_population.append(creature)

func evaluate_and_evolve():
	# Sort population by fitness
	current_population.sort_custom(func(a, b): return a.fitness > b.fitness)
	
	# Store best genes
	best_fitness = current_population[0].fitness
	var best_genes = current_population[0].genes.duplicate()
	
	print("Generation ", generation, " complete")
	print("Best fitness: ", best_fitness)
	
	var new_population = []
	
	# Keep the best performer (elitism)
	# Can be commented out for testing and seeing what happens without it
	var elite = spawn_new_creature(best_genes)
	new_population.append(elite)
	
	# Create rest of new population
	while new_population.size() < POPULATION_SIZE:
		var parent1 = select_parent()
		var parent2 = select_parent()
		var child_genes = crossover(parent1.genes, parent2.genes)
		mutate(child_genes)
		var child = spawn_new_creature(child_genes)
		new_population.append(child)
	
	# Remove old population
	for creature in current_population:
		creature.queue_free()
	
	current_population = new_population
	generation += 1

func select_parent():
	match selection_method:
		SelectionMethod.TOURNAMENT:
			return tournament_selection()
		SelectionMethod.ROULETTE:
			return roulette_selection()
	return tournament_selection()  # Default fallback

func tournament_selection():
	var tournament_size = 3
	var best = null
	var tournament_best_fitness = -1
	
	for i in range(tournament_size):
		var contestant = current_population[randi() % current_population.size()]
		if best == null or contestant.fitness > tournament_best_fitness:
			best = contestant
			tournament_best_fitness = contestant.fitness
	
	return best
	
func roulette_selection():
	# Calculate total fitness
	var total_fitness = 0.0
	for creature in current_population:
		total_fitness += creature.fitness

	# Generate a random point
	var random_point = randf() * total_fitness

	# Find the ball that corresponds to this point
	var current_sum = 0.0
	for creature in current_population:
		current_sum += creature.fitness
		if current_sum > random_point:
			return creature

	# Fallback to last creature just in case it fails for some reason
	return current_population[-1]

# Genes from parent1 and parent2
func crossover(genes1, genes2):
	var new_genes = {}
	# Randomly select genes from either parent
	# TODO : Figure out how the crossover can be made without harcoding, same for mutate
	new_genes.color = genes1.color if randf() < 0.5 else genes2.color

	new_genes.stupidity = genes1.attention_span if randf() < 0.5 else genes2.attention_span
	new_genes.speed = genes1.speed if randf() < 0.5 else genes2.speed
	new_genes.agression = genes1.agression if randf() < 0.5 else genes2.agression
	new_genes.slacking = genes1.slacking if randf() < 0.5 else genes2.slacking
	new_genes.health = genes1.health if randf() < 0.5 else genes2.health
	new_genes.hunger = genes1.hunger if randf() < 0.5 else genes2.hunger

	return new_genes

func mutate(genes):
	if randf() < 0.1:  # 10% mutation chance
		genes.color += Color(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	if randf() < 0.1:
		genes.attention_span += randf_range(-1.0, 1.0)
	if randf() < 0.1:
		genes.speed += randf_range(-1.0, 1.0)
	if randf() < 0.1:
		genes.agression += randf_range(-1.0, 1.0)
	if randf() < 0.1:
		genes.slacking += randf_range(-1.0, 1.0)
	if randf() < 0.1:
		genes.health += randi_range(-1, 1)
	if randf() < 0.1:
		genes.hunger += randi_range(-1, 1)

func spawn_new_creature(genes = null):
	var creature = creature_scene.instantiate()
	add_child(creature)
	creature.position = global_position
	if genes:
		creature.genes = genes.duplicate()
	return creature
