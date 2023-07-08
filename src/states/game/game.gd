extends Node2D


@onready var pause_menu: ColorRect = %PauseMenu


var enemy_moves: Array[Dictionary]
var cards: Array[Resource]
var num_rounds: int = 0
var friendly_health: int = 150
var enemy_health: int = 200


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause()
		get_viewport().set_input_as_handled()


func pause() -> void:
	get_tree().paused = true
	pause_menu.show()


func _on_end_round_button_pressed() -> void:
	upgrade_defenses()
	instant_defensive_damage()
	perpetual_defensive_damage()
	offensive_action_sweep()
	place_new_offenses()
	num_rounds += 1


func upgrade_defenses() -> void:
	pass


func instant_defensive_damage() -> void:
	pass


func perpetual_defensive_damage() -> void:
	# for each defensive square, check if a unit is occupying that square
	# if so, call that unit's defensive_action function
	pass


func offensive_action_sweep() -> void:
	# for each offensive square, check if a unit is occupying that square
	# if so, call that unit's offensive_action function
	pass


func place_new_offenses() -> void:
	pass
