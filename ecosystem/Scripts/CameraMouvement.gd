extends CharacterBody3D

#deplacement camera
const SPEED = 10.0
var mouse_sensitivity = 0.004
var rotating_camera = false

#Parti clic  creature
var target 
var Lastposition : Vector3 = Vector3.ZERO
var distance = 10.0
var hauteur = 5.0
var rotation_speed = 0.05
var horizontal_angle = 0.0
var is_follow : bool
var window

func _ready() -> void:
	is_follow = false
	Lastposition = global_transform.origin
	window = %PopupWindow


func set_target(_target : Node) -> void:
	target = _target
	print(target)
	pass
	
func set_follow(follow: bool)->void:
	Lastposition = global_transform.origin
	is_follow = follow
	pass
	
	
func reset_cam_position() ->void:
	var transform: Transform3D = global_transform
	transform.origin = Lastposition
	global_transform = transform
	is_follow = false
	pass
	
func follow_target()->void:
	if Input.is_action_pressed("move_right"):
		horizontal_angle -= rotation_speed
	if Input.is_action_pressed("move_left"):
		horizontal_angle += rotation_speed
	if Input.is_action_pressed("delock"):
		reset_cam_position()
	
		
	var camera_position = Vector3(
		distance * cos(horizontal_angle),
		hauteur,
		distance * sin(horizontal_angle)
	)
	global_transform.origin = target.global_transform.origin + camera_position
	look_at(target.global_transform.origin, Vector3.UP)

func _physics_process(delta: float) -> void:
		
	if is_follow:
		if target != null:
			window.show()
			follow_target()
	elif target == null || !is_follow:
		window.hide()
		
		var input = Input.get_vector("move_left","move_right","move_up","move_back")
		var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
		
		var vertical = 0.0
		
		if Input.is_action_pressed("up"):
			vertical += 1.0
		if Input.is_action_pressed("down"):
			vertical -= 1.0
		
		velocity.x =  movement_dir.x * SPEED
		velocity.y = vertical * SPEED
		velocity.z = movement_dir.z * SPEED
	pass
	
	

	move_and_slide()
	
func _input(event):
	#print("is_follow",is_follow)
	#print("rotating_camera",rotating_camera)
	# Lorsque l'on clique gauche, on capture la souris
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and !is_follow:
		if event.pressed:
			rotating_camera = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			rotating_camera = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)			
	elif event is InputEventMouseMotion and rotating_camera:
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotation verticale de la caméra
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)

		# Limiter l'angle vertical de la caméra
		var cam_rot = $Camera3D.rotation
		cam_rot.x = clamp(cam_rot.x, -deg_to_rad(70), deg_to_rad(70))
		$Camera3D.rotation = cam_rot
