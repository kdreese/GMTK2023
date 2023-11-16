## Script action which is performed when putting down a card
class_name CardAction
extends Node


var game: GameScene
var data: CardData
var melee_units: Node
var ranged_units: Node
var barricade_units: Node


func initialize(game_scene: Node, card_data: CardData) -> void:
	data = card_data
	game = game_scene
	melee_units = game.get_node("Units/Melee")
	ranged_units = game.get_node("Units/Ranged")
	barricade_units = game.get_node("Units/Barricade")


## An optional function which can prevent an action from being run (and card consumed).
func can_perform(_grid_pos: Vector2i, _is_enemy: bool) -> bool:
	return true


## The action which is performed when the card is dropped. Accepts the card data and position.
func perform_action(_grid_pos: Vector2i, _is_enemy: bool) -> void:
	push_warning("Unimplemented action")


## A list of squares positively affected if the card were to be placed here.
func positive_effects(_grid_pos: Vector2i) -> Array[Vector2i]:
	return []


## A list of squares negatively affected if the card were to be placed here.
func negative_effects(_grid_pos: Vector2i) -> Array[Vector2i]:
	return []


## A list of squares which show up as "hovering" if a card were to be placed here.
func hovering_tiles(grid_pos: Vector2i) -> Array[Vector2i]:
	return [grid_pos]
