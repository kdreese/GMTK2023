extends Control


@onready var quit_button: Button = %QuitButton
@onready var options_menu: Control = $CanvasLayer/OptionsMenu
@onready var credits_menu: ColorRect = $CanvasLayer/CreditsMenu


func _ready() -> void:
	options_menu.get_node("%BackButton").pressed.connect(hide_options)
	credits_menu.get_node("%BackButton").pressed.connect(hide_credits)

	if OS.has_feature("web"):
		quit_button.hide()


func play() -> void:
	Global.curr_stage = 0
	get_tree().change_scene_to_file("res://src/states/game/game.tscn")


func show_options() -> void:
	$UI.hide()
	options_menu.show()


func hide_options() -> void:
	options_menu.hide()
	$UI.show()


func show_credits() -> void:
	$UI.hide()
	credits_menu.show()


func hide_credits() -> void:
	credits_menu.hide()
	$UI.show()


func quit() -> void:
	get_tree().quit()
