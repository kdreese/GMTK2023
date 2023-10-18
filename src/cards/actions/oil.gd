extends CardAction


func can_perform(_data: CardData, grid_pos: Vector2i, _is_enemy: bool) -> bool:
	return grid_pos.x > 6


func perform_action(data: CardData, grid_pos: Vector2i, is_enemy: bool) -> void:
	if data.extra_data.size() != 1:
		push_error("oil expects 1 argument of the damage to do.")
		return

	var sound := game.get_node("Sounds/RightOilSound" if is_enemy else "Sounds/LeftOilSound")
	sound.play()

	await game.wait_for_timer(Global.animation_speed)

	var damage := int(data.extra_data[0])
	for unit in melee_units.get_children():
		if unit.grid_position.x != 7:
			continue

		if (grid_pos.y < 3 and unit.grid_position.y < 3) or (grid_pos.y >= 3 and unit.grid_position.y >= 3):
			unit.health -= damage
			unit.play_damage_sound()
			unit.update_health_bar()

	await game.wait_for_timer(Global.animation_speed)

	for unit in melee_units.get_children():
		if unit.health <= 0:
			unit.queue_free()
