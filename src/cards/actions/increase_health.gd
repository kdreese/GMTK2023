extends CardAction


func can_perform(_data: CardData, _grid_pos: Vector2i, is_enemy: bool) -> bool:
	# Make sure the side isn't already at max health
	var health_bar
	if is_enemy: # The enemy is using this
		health_bar = game.red_castle_health_bar
	else: # We're using this
		health_bar = game.blue_castle_health_bar

	return health_bar.current_health < health_bar.max_health


func perform_action(data: CardData, grid_pos: Vector2i) -> void:
	if data.extra_data.size() != 1:
		push_error("increase_health expects 1 argument of the health to increase")
		return
	var health_bonus := int(data.extra_data[0])
	var health_bar
	if grid_pos.y < 3: # The enemy is using this
		health_bar = game.red_castle_health_bar
		game.get_node("RightHealSound").play()
	else: # We're using this
		health_bar = game.blue_castle_health_bar
		game.get_node("LeftHealSound").play()
	health_bar.modify_health(health_bonus)
