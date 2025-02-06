extends Area3D

var num_fruit : int = 0
var its_time : float = 2.0
var timer : float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= its_time:
		num_fruit += 1
		timer = 0
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D :
		var creature = body as Creature
		if creature.want_eat:
			creature.num_fruit += num_fruit
			num_fruit = 0
			creature.want_eat = false
			creature.want_stock = true
			print("fruit de la creature",creature.num_fruit)
			print("fruit de l'arbre", num_fruit)
		pass
		
	print("Un objet est entré :", body.name)
	pass # Replace with function body.
