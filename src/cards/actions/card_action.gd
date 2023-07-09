## Script action which is performed when putting down a card
class_name CardAction
extends Node


var game: Node
var melee_units: Node
var ranged_units: Node


func set_game(game_scene: Node) -> void:
	game = game_scene
	melee_units = game.get_node("Units/Melee")
	ranged_units = game.get_node("Units/Ranged")



## An optional function which can prevent an action from being run (and card consumed).
func can_perform(_data: CardData, _lane: int) -> bool:
	return true


## The action which is performed when the card is dropped. Accepts the card data and lane
func perform_action(_data: CardData, _lane: int) -> void:
	push_warning("Unimplemented action")
