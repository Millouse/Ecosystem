extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Creature :
		var creature = body as Creature
		if creature.want_eat:
			creature.num_fruit += 1
			creature.want_eat = false
			creature.want_stock = true
			
			creature.choose_new_objective()
			#print("fruit de la creature",creature.num_fruit)
			#print("fruit de l'arbre", num_fruit)
		pass
		
	#print("Un objet est entré :", body.name)
	pass # Replace with function body.
