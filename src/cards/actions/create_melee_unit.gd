## A generic melee unit creation action
extends CardAction


func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	# Don't allow placing units on top of other units.
	if game.get_unit(grid_pos):
		return false
	return grid_pos.x == 0 and (grid_pos.y > 2 if is_enemy else grid_pos.y < 3)


func perform_action(grid_pos: Vector2i, is_enemy: bool) -> void:
	var unit: MeleeUnit = preload("res://src/units/melee_unit.tscn").instantiate()
	if is_enemy:
		game.get_node("Sounds/RightPlaceSound").play()
	else:
		game.get_node("Sounds/LeftPlaceSound").play()
	melee_units.add_child(unit)
	unit.init(data, grid_pos, game.grid_to_world_pos)
