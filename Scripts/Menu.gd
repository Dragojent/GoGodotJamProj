extends Control

var tut = preload("res://Scenes/Tutorial.tscn")

func _on_Button2_pressed():
	get_tree().change_scene_to(tut)

func _on_Button_pressed():
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)
	get_tree().change_scene("res://Scenes/Battle.tscn")
