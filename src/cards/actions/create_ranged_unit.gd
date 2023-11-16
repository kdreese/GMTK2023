## A generic ranged unit creation action
extends CardAction


func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	if not in_own_castle(grid_pos, is_enemy):
		return false
	var unit := game.get_unit(grid_pos)
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
		game.play_sound(game.SoundEffect.PLACE, true)
	else:
		game.play_sound(game.SoundEffect.PLACE, false)
	ranged_units.add_child(new_unit)
	new_unit.init(data, grid_pos, game.grid_to_world_pos)


func negative_effects(grid_pos: Vector2i) -> Array[Vector2i]:
	var output : Array[Vector2i] = []
	for x in range(8 - data.attack_range, 8):
		output.append(Vector2i(x, grid_pos.y))
	return output
