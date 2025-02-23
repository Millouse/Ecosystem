extends Area3D

var num_fruit : int = 0
	
func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D :
		var creature = body as Creature
		if creature.want_stock:
			num_fruit += creature.num_fruit 
			creature.num_fruit = 0
			creature.want_stock = false
			creature.want_eat = true
			print("fruit de la creature",creature.num_fruit)
			print("fruit dans le stockage", num_fruit)
		pass
		
	print("Un objet est entré :", body.name)
	pass # Replace with function body.
