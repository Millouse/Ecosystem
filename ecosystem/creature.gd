extends RigidBody3D
class_name Creature

enum Objective {
	TO_BASE,
	TO_FOOD,
	SLACK,
	ATTACK,
	FLEE
}

@export var tree: Node
@export var base: Node

var jump_delay: float = 1.5
var jump_target: Vector3 = Vector3(0., 0., 0.)
@onready var jump_timer: Timer = %JumpTimer

var current_objective: Objective

var num_fruit: int
var want_stock: bool = false
var want_eat: bool = true

var jump_strength: float = 3.
var max_jump_distance: float = 0.5

var raycast: RayCast3D  # To check if the rigid body is on the ground

# Genes for the object
var genes: Dictionary = {
	"color" = Color(randf(), randf(), randf()),
	"stupidity" = 0.0,
	"speed" = randf(),
	"agression" = randf(),
	"slacking" = randf(),
	"health" = 1,
	"hunger" = 1,
}

func _ready() -> void:
	genes_init()
	jump_target = Vector3(-4., 0., -4.)  # Set the target position
	jump_timer.wait_time = jump_delay
	jump_timer.timeout.connect(move)
	
	jump_target = tree.position

func genes_init():
	var unique_seed = get_instance_id()  # Unique seed for each creature
	seed(unique_seed)  # Set the random seed for this creature
	
	genes["color"] = Color(randf(), randf(), randf())
	genes["stupidity"] = randf()
	genes["speed"] = randf()
	genes["health"] = randi_range(1, 10)
	genes["hunger"] = randi_range(0, 2)


func move() -> void:		
	var to_target = jump_target - global_transform.origin
	var distance = to_target.length()
	
	# If already close to the target, stop jumping
	if distance < max_jump_distance:
		print("Reached target")
		if (want_eat):
			want_eat = false
			want_stock = true
			jump_target = base.position
		else:
			want_eat = true
			want_stock = false
			jump_target = tree.position
		return
	
	# Calculate direction to target (horizontal component only)
	var jump_direction = Vector3(to_target.x, 0, to_target.z).normalized()

	# Scale the horizontal movement so it doesn't exceed max_jump_distance
	if distance < max_jump_distance:
		jump_direction *= distance  # Small final jump
	else:
		jump_direction *= max_jump_distance  # Limit distance moved in one jump
	
	# Add a consistent upward impulse for the jump
	var impulse = Vector3(jump_direction.x, jump_strength, jump_direction.z)
	var deviation_strength = genes["stupidity"] * 0.5  # Scale the deviation by stupidity
	var deviation_x = randf_range(-deviation_strength, deviation_strength)
	var deviation_z = randf_range(-deviation_strength, deviation_strength)
	impulse.x += deviation_x
	impulse.z += deviation_z
	
	# Apply the impulse to the RigidBody3D
	apply_impulse(impulse)

	print("Jumping towards", jump_target)

func choose_new_objective() -> void:
	var roll: float = randf()
	if (roll < genes["slacking"]):
		current_objective = Objective.SLACK
	else:
		if (want_eat):
			current_objective = Objective.TO_FOOD
			jump_target = tree.position
		elif (want_stock):
			current_objective = Objective.TO_BASE
			jump_target = base.position
			
	print("New objective : " + str(current_objective))

func _on_body_entered(body: Node) -> void:
	if (body.name == "Ground"):
		print("Stopping")
		# Stop movement when grounded to prevent sliding
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
