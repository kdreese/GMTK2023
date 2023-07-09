extends CardAction


func can_perform(_data: CardData, lane: int) -> bool:
	# Make sure the side isn't already at max health
	var health_bar
	if lane < 3: # The enemy is using this
		health_bar = game.blue_castle_health_bar
	else: # We're using this
		health_bar = game.red_castle_health_bar

	return health_bar.current_health < health_bar.max_health


func perform_action(data: CardData, lane: int) -> void:
	if data.extra_data.size() != 1:
		push_error("increase_health expects 1 argument of the health to increase")
		return
	var health_bonus := int(data.extra_data[0])
	var health_bar
	if lane < 3: # The enemy is using this
		health_bar = game.blue_castle_health_bar
	else: # We're using this
		health_bar = game.red_castle_health_bar
	health_bar.current_health += health_bonus
	if health_bar.current_health > health_bar.max_health:
		health_bar.current_health = health_bar.max_health
	health_bar.update()
