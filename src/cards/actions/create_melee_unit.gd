## A generic melee unit creation action
extends CardAction


func perform_action(data: CardData, lane: int) -> void:
	var unit: MeleeUnit = preload("res://src/units/melee_unit.tscn").instantiate()
	if lane < 3:
		game.get_node("LeftPlaceSound").play()
	else:
		game.get_node("RightPlaceSound").play()
	melee_units.add_child(unit)
	unit.init(data, lane)
