## A generic ranged unit creation action
extends CardAction


func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	if not (grid_pos.x > 7 and (grid_pos.y < 3 if is_enemy else grid_pos.y > 2)):
		return false
	var unit = game.get_unit(grid_pos)
	# Only allow placement if this is a better unit.
	if unit != null and unit is RangedUnit:
		return data.rank > unit.rank
	return true


func perform_action(grid_pos: Vector2i, is_enemy: bool) -> void:
	var new_unit: RangedUnit = preload("res://src/units/ranged_unit.tscn").instantiate()
	for unit in ranged_units.get_children():
		if unit.grid_position == grid_pos:
			ranged_units.remove_child(unit)
			unit.queue_free()
	if is_enemy:
		game.get_node("Sounds/LeftPlaceSound").play()
	else:
		game.get_node("Sounds/RightPlaceSound").play()
	ranged_units.add_child(new_unit)
	new_unit.init(data, grid_pos, game.grid_to_world_pos)
