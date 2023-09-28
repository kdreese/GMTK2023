## A generic melee unit creation action
extends CardAction


func can_perform(_data: CardData, grid_pos: Vector2i, is_enemy: bool) -> bool:
	return grid_pos.x == 0 and (grid_pos.y > 2 if is_enemy else grid_pos.y < 3)


func perform_action(data: CardData, grid_pos: Vector2i, is_enemy: bool) -> void:
	var unit: MeleeUnit = preload("res://src/units/melee_unit.tscn").instantiate()
	if is_enemy:
		game.get_node("RightPlaceSound").play()
	else:
		game.get_node("LeftPlaceSound").play()
	melee_units.add_child(unit)
	unit.init(data, grid_pos, game.grid_to_world_pos)
