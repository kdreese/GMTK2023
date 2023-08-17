## A generic ranged unit creation action
extends CardAction


func perform_action(data: CardData, lane: int) -> void:
	var unit: RangedUnit = preload("res://src/units/ranged_unit.tscn").instantiate()
	unit.grid_position = Vector2i(0, lane)
	ranged_units.add_child(unit)
	unit.init(data, lane)
