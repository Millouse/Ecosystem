extends CharacterBody3D

const SPEED = 5.0
var mouse_sensitivity = 0.002
var rotating_camera = false


func _physics_process(delta: float) -> void:
	
	var input = Input.get_vector("move_left","move_right","move_up","move_back")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	
	var vertical = 0.0
	
	if Input.is_action_pressed("up "):
		vertical += 1.0
	if Input.is_action_pressed("down"):
		vertical -= 1.0
	
	velocity.x =  movement_dir.x * SPEED
	velocity.y = vertical * SPEED
	velocity.z = movement_dir.z * SPEED
	

	move_and_slide()
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			rotating_camera = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			rotating_camera = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)			
	elif event is InputEventMouseMotion and rotating_camera:
		rotate_y(-event.relative.x * mouse_sensitivity)

		$MainCamera.rotate_x(-event.relative.y * mouse_sensitivity)

		var cam_rot = $MainCamera.rotation
		cam_rot.x = clamp(cam_rot.x, -deg_to_rad(70), deg_to_rad(70))
		$MainCamera.rotation = cam_rot
