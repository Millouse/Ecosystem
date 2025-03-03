extends PopupPanel

var cam : Node3D
var stupidity : Label
var  speed: Label
var agression : Label
var slacking : Label
var health : Label
var hunger : Label
var vbox : VBoxContainer
var margin_container: MarginContainer
var center: CenterContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam = get_node("%MainCamera")
	center = CenterContainer.new()
	margin_container = MarginContainer.new()
	vbox = VBoxContainer.new()
	stupidity = Label.new()
	speed = Label.new()
	agression = Label.new()
	slacking = Label.new()
	health = Label.new()
	hunger = Label.new()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(cam.target != null):
		var creature = cam.target
	
		margin_container.add_theme_constant_override("margin_left", 10)
		margin_container.add_theme_constant_override("margin_top", 60)
		
		# Si besoin, vous pouvez ajuster ses marges pour positionner le container dans le PopupPanel

		# Création et configuration du label pour "stupidity"
		stupidity.text = "Stupidity : " + String("%.2f" % creature.genes["stupidity"])
		# On ajoute le label au container, le container se charge de la position
		
		var separator1 = HSeparator.new()
		# Création et configuration du label pour "speed"
		speed.text = "Speed : " + String("%.2f" % creature.genes["speed"])
		
		var separator2 = HSeparator.new()

		agression.text = "Agression : "+ str("%.2f" % creature.genes["agression"])
		#agression.position = Vector2(10, 140)
		var separator3 = HSeparator.new()
	
		slacking.text = "Slacking : "+ str("%.2f" % creature.genes["slacking"])
		#slacking.position = Vector2(10, 180)
		var separator4 = HSeparator.new()
	
		health.text = "Health : "+ str(creature.genes["health"])
		#health.position = Vector2(10, 220)
		var separator5 = HSeparator.new()
		
		hunger.text = "Hunger : "+ str(creature.genes["hunger"])
		#hunger.position = Vector2(10, 260)
		
		
		if center not in get_children():
			add_child(center)
			center.add_child(margin_container)
			margin_container.add_child(vbox)
			vbox.add_child(stupidity)
			vbox.add_child(separator1)
			vbox.add_child(speed)
			vbox.add_child(separator2)
			vbox.add_child(slacking)
			vbox.add_child(separator3)
			vbox.add_child(agression)
			vbox.add_child(separator4)
			vbox.add_child(health)
			vbox.add_child(separator5)
			vbox.add_child(hunger)
		
	pass
