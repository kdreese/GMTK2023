# @tool
extends CardAction

## Docstring
# Signals
# Enums
# Constants
# Exported Variables
# Variables
# Onready Variables
# Built-in Functions


# Other Functions
func enemy_filter_func(unit: Unit) -> bool:
	return unit.grid_position.y > 2 and unit.grid_position.x < 8


func ally_filter_func(unit: Unit) -> bool:
	return unit.grid_position.y <= 2 and unit.grid_position.x < 8


## An optional function which can prevent an action from being run (and card consumed).
func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	# Only allow placing on the attacking unit field.
	if not (in_attacking_area(grid_pos, is_enemy) or in_staging_area(grid_pos, is_enemy)):
		return false

	# Don't let them use this unless they have at least one unit on the field that can move.
	var filter_func = enemy_filter_func if is_enemy else ally_filter_func
	return len(melee_units.get_children().filter(filter_func)) > 0


## The action which is performed when the card is dropped. Accepts the card data and position.
func perform_action(_grid_pos: Vector2i, is_enemy: bool) -> void:
	var filter_func = enemy_filter_func if is_enemy else ally_filter_func

	game.play_sound(game.SoundEffect.CHARGE, not is_enemy)

	var units = melee_units.get_children().filter(filter_func)
	for unit in units as Array[MeleeUnit]:
		# Do we want to be able to stack buffs?
		unit.extra_stats["speed"] = data.movement


func positive_effects(_grid_pos: Vector2i) -> Array[Vector2i]:
	var units := melee_units.get_children().filter(ally_filter_func)
	var positions: Array[Vector2i] = []
	for unit in units:
		positions.append(unit.grid_position)
	return positions


func hovering_tiles(_grid_pos: Vector2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for y in range(3):
		for x in range(8):
			tiles.append(Vector2i(x, y))
	return tiles
