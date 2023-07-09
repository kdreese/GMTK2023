extends CardAction


func perform_action(data: CardData, lane: int) -> void:
	if data.extra_data.size() != 1:
		push_error("oil expects 1 argument of the damage to do.")
		return
	var damage := int(data.extra_data[0])
	for unit in melee_units.get_children():
		if unit.grid_position.x != 7:
			continue

		if (lane < 3 and unit.grid_position.y < 3) or (lane >= 3 and unit.grid_position.y >= 3):
			unit.health -= damage
			unit.update_health_bar()
			if unit.health <= 0:
				unit.queue_free()

