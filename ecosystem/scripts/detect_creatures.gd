extends RayCast3D

var cam : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam = get_node("%MainCamera")
	pass

func selection_mouse(event : InputEvent)->void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = get_viewport().get_mouse_position();
		var start = get_viewport().get_camera_3d().project_ray_origin(mouse_position)
		var direction = get_viewport().get_camera_3d().project_ray_normal(mouse_position)
		global_transform.origin = start
		target_position = direction * 100  # This is now correctly relative to origin
		force_raycast_update()  # Force the raycast to update before checking collision
		if(is_colliding()):
			var collider = get_collider()
			collider = collider as Creature
			if(collider as Creature):
				cam.set_target(collider)
				cam.is_follow = true
			pass
	
func _input(event: InputEvent) -> void:
	selection_mouse(event)
	if Input.is_action_pressed("delock"):
		cam.reset_cam_position()
		print("arrete de me suivre")
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
