extends CardAction
## Lightning strike action


# Other Functions
func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	return grid_pos.x > 7 and (grid_pos.y > 2 if is_enemy else grid_pos.y < 3)


func perform_action(grid_pos: Vector2i, is_enemy: bool) -> void:
	if data.extra_data.size() != 2:
		push_error("lightning expects 2 argument of the damage to do.")
		return

	await game.wait_for_timer(Global.animation_speed)

	var castle_damage := int(data.extra_data[0])
	var unit_damage := int(data.extra_data[1])

	if is_enemy:
		game.blue_castle_health_bar.modify_health(-castle_damage)
	else:
		game.red_castle_health_bar.modify_health(-castle_damage)
	game.check_for_end_condition()
	if game.game_over:
		return

	for unit in melee_units.get_children():
		if unit.grid_position.x != 7:
			continue

		if (grid_pos.y < 3 and unit.grid_position.y < 3) or (grid_pos.y >= 3 and unit.grid_position.y >= 3):
			unit.health -= unit_damage
			unit.play_damage_sound()
			unit.update_health_bar()

	await game.wait_for_timer(Global.animation_speed)

	for unit in melee_units.get_children():
		if unit.health <= 0:
			unit.commit_die()


func negative_effects(_grid_pos: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0),
		Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1), Vector2i(10, 1),
		Vector2i(7, 2), Vector2i(8, 2), Vector2i(9, 2), Vector2i(10, 2),
	]
