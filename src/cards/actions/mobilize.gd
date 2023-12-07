# @tool
class_name Mobilize
extends CardAction

## Docstring


# Signals


# Enums


# Constants
const POOLS: Array[CardPool] = [
	preload("res://src/cards/attack/attack_1_pool.tres"),
	preload("res://src/cards/attack/attack_2_pool.tres"),
	preload("res://src/cards/attack/attack_3_pool.tres"),
]

const NUM_CARDS = 2

# Exported Variables


# Variables


# Onready Variables


# Built-in Functions


# Other Functions
## An optional function which can prevent an action from being run (and card consumed).
func can_perform(grid_pos: Vector2i, is_enemy: bool) -> bool:
	# Check to make sure this is the archer grid.
	if not in_own_castle(grid_pos, is_enemy):
		return false

	# Get the archer unit.
	var archer := game.get_unit(grid_pos)
	if archer == null or not (archer is RangedUnit):
		return false

	if data.rank < archer.rank:
		return false

	return true


## The action which is performed when the card is dropped. Accepts the card data and position
func perform_action(grid_pos: Vector2i, is_enemy: bool) -> void:
	# Get the archer unit.
	var archer := game.get_unit(grid_pos)
	if archer == null or not (archer is RangedUnit):
		return

	var rank := archer.rank as int
	ranged_units.remove_child(archer)
	archer.queue_free()

	for drop_point in game.get_node("DropPoints").get_children():
		drop_point.close_tooltip()

	if not is_enemy:
		# Rank is 1-indexed, arrays are 0-indexed.
		var pool := POOLS[rank - 1]
		pool.reset()
		for _idx in range(NUM_CARDS):
			var card := DualCardData.new(pool.take_card(), null)
			card.single_use = true
			await game.draw_specific_card(card)


func negative_effects(grid_pos: Vector2i) -> Array[Vector2i]:
	return [grid_pos]

# Subclass Definitions

