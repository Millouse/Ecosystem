extends Node

func _input(event):
	if Input.is_action_just_pressed("algo_gen_scene"):
		get_tree().change_scene_to_file("res://scenes/game_of_life.tscn")
	if Input.is_action_just_pressed("game_of_life_scene"):
		get_tree().change_scene_to_file("res://scenes/game_of_life.tscn")
