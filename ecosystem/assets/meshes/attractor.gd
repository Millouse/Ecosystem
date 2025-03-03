extends Node3D

func _process(delta: float) -> void:
	rotate_y(0.5 * delta)  # Adjust 0.5 to control rotation speed
