class_name Creature extends RigidBody3D

enum Objective {
	TO_BASE,
	TO_FOOD,
	SLACK,
	ATTACK,
	FLEE
}

@export var tree: Node
@export var base: Node

var jump_target: Vector3 = Vector3(0., 0., 0.)
@onready var jump_timer: Timer = %JumpTimer
@onready var slack_timer: Timer = %SlackTimer

@onready var slime_mesh: MeshInstance3D = %Mesh

var current_objective: Objective

var num_fruit: int
var want_stock: bool = false
var want_eat: bool = true

var jump_strength: float = 3.
var max_jump_distance: float = 0.75

var slack_max_distance: float = 3.0 # When slacking, creature goes somewhere random in this range

var raycast: RayCast3D  # To check if the rigid body is on the ground

@export var team: int # Export for testing purposes
var enemy: RigidBody3D = null
var kill_count: int = 0

# Genes for the object
var genes: Dictionary = {
	"color" = Color(randf(), randf(), randf()),
	"stupidity" = 0.0, # Adds random deviation to jump
	"speed" = 1.0 + randf(), # Minimum of 1 second
	"agression" = randf(), # To know if creatures attacks or flees when meeting another TODO : change radius aswell
	"slacking" = randf(), # Chance to do nothing and go take a nap
	"health" = 1,
	"hunger" = 1,
}
var fitness # TODO : Figure out what fitness will be. Maybe stocked food / kills ?

func _ready() -> void:
	genes_init() # WARNING : That may fuck up crossover / mutation !
	var body_material: Material = slime_mesh.get_surface_override_material(0)
	var new_material := body_material.duplicate()
	new_material.albedo_color = genes.color
	slime_mesh.set_surface_override_material(0, new_material)
	choose_new_objective()
	
	jump_timer.wait_time = genes["speed"]
	jump_timer.timeout.connect(move)
	
	slack_timer.timeout.connect(_on_slack_timer_timeout)

func _process(_delta: float) -> void:
	if (genes["health"] <= 0):
		queue_free() # Just remove the entity for now

func genes_init():
	var unique_seed = get_instance_id()  # Unique seed for each creature
	seed(unique_seed)  # Set the random seed for this creature
	
	genes["color"] = Color(randf(), randf(), randf())
	genes["stupidity"] = randf()
	genes["speed"] = 1.0 + randf()
	genes["health"] = 1 # randi_range(1, 10) # Set to 1 for test
	genes["hunger"] = randi_range(0, 2)

func move() -> void:
	if current_objective == Objective.ATTACK:
		if enemy == null or enemy.genes["health"] <= 0:
			choose_new_objective()
			return
		else:
			jump_target = enemy.position

	var to_target = jump_target - global_transform.origin
	var distance = to_target.length()

	# Only switch objective if not attacking/slacking and close to target
	if (distance < max_jump_distance and current_objective not in [Objective.SLACK, Objective.ATTACK]):
		choose_new_objective()
		return
	
	# Calculate direction to target (horizontal component only)
	var jump_direction = Vector3(to_target.x, 0, to_target.z).normalized()
	var target_basis = Basis.looking_at(-jump_direction)
	global_transform.basis = target_basis # Rotate towards jump direction

	# Scale the horizontal movement so it doesn't exceed max_jump_distance
	if (distance < max_jump_distance):
		jump_direction *= distance  # Small final jump
	else:
		jump_direction *= max_jump_distance  # Limit distance moved in one jump
	
	# Add a consistent upward impulse for the jump
	var impulse = Vector3(jump_direction.x, jump_strength, jump_direction.z)
	var deviation_strength = genes["stupidity"] * 0.5  # Scale the deviation by stupidity
	var deviation = Vector3(randf_range(-deviation_strength, deviation_strength),
	0,
	randf_range(-deviation_strength, deviation_strength))
	impulse += deviation
	
	# Apply the impulse to the RigidBody3D
	apply_impulse(impulse)

	#print("Jumping towards", jump_target)

func choose_new_objective() -> void:
	if (current_objective == Objective.ATTACK):
		enemy = null # Reset enemy reference
	
	var roll: float = randf()
	if (roll < genes["slacking"]):
		current_objective = Objective.SLACK
		jump_target = generate_slack_target()
		slack_timer.start()
	else:
		if (want_eat):
			current_objective = Objective.TO_FOOD
			want_eat = false
			want_stock = true
			jump_target = tree.position
		elif (want_stock):
			current_objective = Objective.TO_BASE
			want_eat = true
			want_stock = false
			jump_target = base.position
			
	#print("New objective : " + str(current_objective))
	
func generate_slack_target() -> Vector3:
	var current_pos = global_transform.origin
	var random_angle = randf_range(0, 2 * PI)
	var distance = randf_range(1.0, slack_max_distance)
	var offset = Vector3(cos(random_angle) * distance, 0, sin(random_angle) * distance)
	return current_pos + offset

func _on_slack_timer_timeout():
	choose_new_objective()

func _on_body_entered(body: Node) -> void:
	if (body.name == "Ground"):
		#print("Stopping")
		# Stop movement when grounded to prevent sliding
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	if (body as Creature):
		var enemy_creature = body as Creature
		if (randf() < 0.7): # 70% chance of dealing damage - need to do better later
			print("Dealing damage !")
			enemy_creature.genes["health"] -= 1
			if (enemy_creature.genes["health"] <= 0):
				print("Killed !")
				kill_count += 1
				choose_new_objective()

func _on_agression_area_body_entered(body: Node3D) -> void:
	print("Agression body entered" + body.name)
	if body is RigidBody3D:
		var creature = body as Creature
		if (creature.team != team):
			var roll: float = randf()
			if (roll < genes["agression"]):
				print("Attacking")
				current_objective = Objective.ATTACK
				jump_target = creature.position
				enemy = creature
			else:
				print("Fleeing")
				current_objective = Objective.FLEE
				var current_pos = global_transform.origin
				var random_angle = randf_range(0, 2 * PI)
				var distance = 5
				var offset = Vector3(cos(random_angle) * distance, 0, sin(random_angle) * distance)
				jump_target = current_pos + offset
				
