## Creates a barricade, which is a defense card in your attack range
extends CardAction


func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	if not in_defending_area(grid_pos, is_enemy) or grid_pos.x == 1:
		return false
	if game.get_unit(grid_pos) != null:
		return false
	return true


func perform_action(grid_pos: Vector2i, is_enemy: bool) -> void:
	var new_unit: BarricadeUnit = preload("res://src/units/barricade_unit.tscn").instantiate()
	game.play_sound(game.SoundEffect.PLACE, not is_enemy)
	barricade_units.add_child(new_unit)
	new_unit.init(data, grid_pos, game.grid_to_world_pos)


## A list of squares positively affected if the card were to be placed here.
func positive_effects(grid_pos: Vector2i) -> Array[Vector2i]:
	return [grid_pos]


## A list of squares positively affected if the card were to be placed here.
func negative_effects(grid_pos: Vector2i) -> Array[Vector2i]:
	var out : Array[Vector2i] = []
	for x in range(1, grid_pos.x):
		out.append(Vector2i(x, grid_pos.y))
	return out
