## Creates a barricade, which is a defense card in your attack range
extends CardAction


func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	if grid_pos.x < 1 or grid_pos.x > 7:
		return false
	if is_enemy:
		if grid_pos.y > 2:
			return false
	else:
		if grid_pos.y < 3:
			return false
	if game.get_unit(grid_pos) != null:
		return false
	return true


func perform_action(grid_pos: Vector2i, is_enemy: bool) -> void:
	var new_unit: BarricadeUnit = preload("res://src/units/barricade_unit.tscn").instantiate()
	for unit in barricade_units.get_children():
		if unit.grid_position == grid_pos:
			barricade_units.remove_child(unit)
			unit.queue_free()
	game.play_sound(game.SoundEffect.PLACE, not is_enemy)
	barricade_units.add_child(new_unit)
	new_unit.init(data, grid_pos, game.grid_to_world_pos)
	new_unit.max_health = int(data.extra_data[0])
	new_unit.health = new_unit.max_health
