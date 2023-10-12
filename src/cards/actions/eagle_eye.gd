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
# Other Functions
func enemy_filter_func(unit: Unit) -> bool:
	return unit.grid_position.y <= 2 and unit.grid_position.x >= 8

func ally_filter_func(unit: Unit) -> bool:
	return unit.grid_position.y > 2 and unit.grid_position.x >= 8

## An optional function which can prevent an action from being run (and card consumed).
func can_perform(_data: CardData, grid_pos: Vector2i, is_enemy: bool) -> bool:
	# Only allow placing on the archer unit field.
	if not (grid_pos.x >= 8 and (grid_pos.y <= 2 if is_enemy else grid_pos.y > 2)):
		return false

	# Don't let them use this unless they have at least one unit on the field that can move.
	var filter_func = enemy_filter_func if is_enemy else ally_filter_func
	return len(ranged_units.get_children().filter(filter_func)) > 0


## The action which is performed when the card is dropped. Accepts the card data and position.
func perform_action(data: CardData, _grid_pos: Vector2i, is_enemy: bool) -> void:
	var filter_func = enemy_filter_func if is_enemy else ally_filter_func

	if len(data.extra_data) < 1:
		push_error("No extra data, cannot get range increase.")
		return

	var extra_range := int(data.extra_data[0])

	var units = ranged_units.get_children().filter(filter_func)
	for unit in units as Array[RangedUnit]:
		unit.extra_stats["attack_range"] = extra_range

# Subclass Definitions

