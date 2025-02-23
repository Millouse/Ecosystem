extends Camera3D

var target 

var Lastposition : Vector3 = Vector3.ZERO


var distance = 1.0
var hauteur = 1.0

var rotation_speed = 0.05
var horizontal_angle = 0.0

var is_follow : bool
var window

func _ready() -> void:
	is_follow = false
	Lastposition = global_transform.origin
	window = %PopupWindow
	print(target)

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
		
	var camera_position = Vector3(
		distance * cos(horizontal_angle),
		hauteur,
		distance * sin(horizontal_angle)
	)
	global_transform.origin = target.global_transform.origin + camera_position
	look_at(target.global_transform.origin, Vector3.UP)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if is_follow:
		if target != null:
			window.show()
			follow_target()
	else:
		window.hide()
	pass
