extends CardAction


func get_squares(grid_pos: Vector2i) -> Array[Vector2i]:
	return [
		grid_pos, grid_pos + Vector2i(-1, 0),
		grid_pos + Vector2i(0, 1), grid_pos + Vector2i(-1, 1)
	]


## An optional function which can prevent an action from being run (and card consumed).
func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	return in_defending_area(grid_pos, is_enemy) and grid_pos.x != 1 and grid_pos.y not in [2, 5]


## The action which is performed when the card is dropped. Accepts the card data and position.
func perform_action(grid_pos: Vector2i, _is_enemy: bool) -> void:
	if len(data.extra_data) < 1:
		push_error("No extra data found")

	var damage = int(data.extra_data[0])

	var squares := get_squares(grid_pos)
	game.play_sound(game.SoundEffect.TREBUCHET)

	await get_tree().create_timer(1.5).timeout

	for square in squares:
		var unit := game.get_unit(square)
		if unit:
			unit.health -= damage
			unit.update_health_bar()
			if unit.health <= 0:
				melee_units.remove_child(unit)
				unit.queue_free()


## A list of squares negatively affected if the card were to be placed here.
func negative_effects(grid_pos: Vector2i) -> Array[Vector2i]:
	return get_squares(grid_pos)

