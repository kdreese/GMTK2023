## A generic ranged unit creation action
extends CardAction


func can_perform(_data: CardData, grid_pos: Vector2i, is_enemy: bool) -> bool:
	return grid_pos.x > 7 and (grid_pos.y < 3 if is_enemy else grid_pos.y > 2)


func perform_action(data: CardData, grid_pos: Vector2i, is_enemy: bool) -> void:
	var new_unit: RangedUnit = preload("res://src/units/ranged_unit.tscn").instantiate()
	for unit in ranged_units.get_children():
		if unit.grid_position == grid_pos:
			ranged_units.remove_child(unit)
			unit.queue_free()
	if is_enemy:
		game.get_node("LeftPlaceSound").play()
	else:
		game.get_node("RightPlaceSound").play()
	ranged_units.add_child(new_unit)
	new_unit.init(data, grid_pos, game.grid_to_world_pos)
