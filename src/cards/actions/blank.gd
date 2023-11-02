## Script action which is performed when putting down a card
extends CardAction


func initialize(game_scene: Node, card_data: CardData) -> void:
	data = card_data
	game = game_scene
	melee_units = game.get_node("Units/Melee")
	ranged_units = game.get_node("Units/Ranged")


## An optional function which can prevent an action from being run (and card consumed).
func can_perform(_grid_pos: Vector2i, _is_enemy: bool) -> bool:
	return false

