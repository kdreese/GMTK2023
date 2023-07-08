extends Control


@onready var options_menu: Control = $CanvasLayer/OptionsMenu


func _ready() -> void:
	options_menu.get_node("CenterContainer/VBoxContainer/BackButton").pressed.connect(hide_options)


func play() -> void:
	get_tree().change_scene_to_file("res://src/states/game/game.tscn")


func show_options() -> void:
	$UI.hide()
	options_menu.show()


func hide_options() -> void:
	options_menu.hide()
	$UI.show()


func credits() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/credits_menu.tscn")


func quit() -> void:
	get_tree().quit()
