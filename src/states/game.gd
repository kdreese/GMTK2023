extends Node2D


var enemyMoves: Array[Dictionary]
var cards: Array[Resource]
var numRounds: int = 0
var friendlyHealth: int = 150
var enemyHealth: int = 200


func _ready() -> void:
	pass


func _on_end_round_button_pressed() -> void:
	upgrade_defenses()
	instant_defensive_damage()
	perpetual_defensive_damage()
	offensive_action_sweep()
	place_new_offenses()
	numRounds += 1


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
