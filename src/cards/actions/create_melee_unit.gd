## A generic melee unit creation action
extends CardAction


func perform_action(data: CardData, lane: int) -> void:
	var unit: MeleeUnit = preload("res://src/units/melee_unit.tscn").instantiate()
	melee_units.add_child(unit)
	unit.init(data, lane)
