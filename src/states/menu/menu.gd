extends Control


func play() -> void:
	pass


func options() -> void:
	pass


func credits() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/credits_menu.tscn")


func quit() -> void:
	get_tree().quit()
