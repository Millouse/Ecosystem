extends RigidBody3D

var jump_delay: float = 1.5
var jump_target: Vector3 = Vector3(0., 0., 0.)
var jump_timer: Timer

var jump_strength: float = 5.0  # Adjust this value for jump force
var max_jump_distance: float = 1.0  # Limit for horizontal movement per jump

var raycast: RayCast3D  # To check if the rigid body is on the ground

# Genes for the object
var genes: Dictionary = {
	"color" = Color(randf(), randf(), randf()),
	"attention_span" = randf(),
	"speed" = randf(),
}

func _ready() -> void:
	jump_target = Vector3(-4., 0., -4.)  # Set the target position
	jump_timer = Timer.new()
	jump_timer.wait_time = jump_delay
	jump_timer.autostart = true
	jump_timer.timeout.connect(move)
	add_child(jump_timer)

func move() -> void:		
	var to_target = jump_target - global_transform.origin
	var distance = to_target.length()
	
	# If already close to the target, stop jumping
	if distance < max_jump_distance:
		print("Reached target")
		jump_timer.stop()
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
	
	# Apply the impulse to the RigidBody3D
	apply_impulse(impulse)

	print("Jumping towards", jump_target)

func _on_body_entered(body: Node) -> void:
	if (body.name == "Ground"):
		print("Stopping")
		# Stop horizontal movement when grounded to prevent sliding
		var velocity = linear_velocity
		velocity.x = 0
		velocity.y = 0
		velocity.z = 0
		linear_velocity = velocity
		print(angular_velocity)
