extends Area3D

var num_fruit : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D :
		if body.want_stock:
			num_fruit += body.num_fruit 
			body.num_fruit = 0
			body.want_stock = false
			body.want_eat = true
			print("fruit de la creature",body.num_fruit)
			print("fruit dans le stockage", num_fruit)
		pass
		
	print("Un objet est entré :", body.name)
	pass # Replace with function body.
