extends Control


@onready var title: Label = $UI/Title
@onready var buttons: VBoxContainer = $UI/Buttons
@onready var fanfare: AudioStreamPlayer = %Fanfare
@onready var background_texture: TextureRect = $Background/BackgroundTexture


func play() -> void:
	pass


func options() -> void:
	pass


func credits() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/credits_menu.tscn")


func quit() -> void:
	get_tree().quit()
