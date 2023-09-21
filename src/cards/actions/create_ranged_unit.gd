## A generic ranged unit creation action
extends CardAction


func perform_action(data: CardData, grid_pos: Vector2i) -> void:
	var new_unit: RangedUnit = preload("res://src/units/ranged_unit.tscn").instantiate()
	for unit in ranged_units.get_children():
		if unit.grid_position == grid_pos:
			ranged_units.remove_child(unit)
			unit.queue_free()
	if grid_pos.y < 3:
		game.get_node("RightPlaceSound").play()
	else:
		game.get_node("LeftPlaceSound").play()
	ranged_units.add_child(new_unit)
	new_unit.init(data, grid_pos)
