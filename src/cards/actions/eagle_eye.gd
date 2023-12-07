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
	return in_own_castle(unit.grid_position, true)


func ally_filter_func(unit: Unit) -> bool:
	return in_own_castle(unit.grid_position)


## An optional function which can prevent an action from being run (and card consumed).
func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	# Only allow placing on the archer unit field.
	if not in_own_castle(grid_pos, is_enemy):
		return false

	# Don't let them use this unless they have at least one ranged unit.
	var filter_func := enemy_filter_func if is_enemy else ally_filter_func
	return len(ranged_units.get_children().filter(filter_func)) > 0


## The action which is performed when the card is dropped. Accepts the card data and position.
func perform_action(_grid_pos: Vector2i, is_enemy: bool) -> void:
	var filter_func := enemy_filter_func if is_enemy else ally_filter_func

	var units: Array[RangedUnit] = ranged_units.get_children().filter(filter_func)
	for unit in units as Array[RangedUnit]:
		unit.extra_stats["attack_range"] = unit.extra_stats.get("attack_range", 0) + data.att_range


func positive_effects(_grid_pos: Vector2i) -> Array[Vector2i]:
	var units: Array[RangedUnit] = []
	units.assign(ranged_units.get_children().filter(ally_filter_func))
	var positions: Array[Vector2i] = []
	for unit in units:
		positions.append(unit.grid_position)
	return positions


func hovering_tiles(_grid_pos: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(8, 3), Vector2i(9, 3), Vector2i(10, 3),
		Vector2i(8, 4), Vector2i(9, 4), Vector2i(10, 4),
		Vector2i(8, 5), Vector2i(9, 5), Vector2i(10, 5),
	]
