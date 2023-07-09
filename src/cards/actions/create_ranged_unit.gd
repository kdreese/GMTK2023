## A generic melee unit creation action
extends CardAction


func perform_action(data: CardData, lane: int) -> void:
	var unit: Unit = preload("res://src/units/unit.tscn").instantiate()
	ranged_units.add_child(unit)
	unit.init(data, lane)
