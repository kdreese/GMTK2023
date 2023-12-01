extends CardAction


func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	if not in_own_castle(grid_pos, is_enemy):
		return false
	# Make sure the side isn't already at max health
	var health_bar: CastleHealthBar
	if is_enemy: # The enemy is using this
		health_bar = game.red_castle_health_bar
	else: # We're using this
		health_bar = game.blue_castle_health_bar

	return health_bar.current_health < health_bar.max_health


func perform_action(_grid_pos: Vector2i, is_enemy: bool) -> void:
	var health_bar: CastleHealthBar
	if is_enemy: # The enemy is using this
		health_bar = game.red_castle_health_bar
		game.play_sound(game.SoundEffect.HEAL, false)
	else: # We're using this
		health_bar = game.blue_castle_health_bar
		game.play_sound(game.SoundEffect.HEAL, true)
	health_bar.modify_health(data.health)


func positive_effects(_grid_pos: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(8, 3), Vector2i(9, 3), Vector2i(10, 3),
		Vector2i(8, 4), Vector2i(9, 4), Vector2i(10, 4),
		Vector2i(8, 5), Vector2i(9, 5), Vector2i(10, 5),
	]


func hovering_tiles(_grid_pos: Vector2i) -> Array[Vector2i]:
	return positive_effects(_grid_pos)
