## Script action which is performed when putting down a card
class_name CardAction
extends Node


const ALLY_CASTLE_AREA = Rect2i(8, 3, 3, 3)
const ALLY_STAGING_AREA = Rect2i(0, 0, 1, 3)
const ALLY_ATTACKING_AREA = Rect2i(1, 0, 7, 3)

const ENEMY_CASTLE_AREA = Rect2i(8, 0, 3, 3)
const ENEMY_STAGING_AREA = Rect2i(0, 3, 1, 3)
const ENEMY_ATTACKING_AREA = Rect2i(1, 3, 7, 3)


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


## Return true if the position is in the staging area as indicated by is_enemy.
func in_staging_area(grid_pos: Vector2i, is_enemy := false) -> bool:
	if is_enemy:
		return ENEMY_STAGING_AREA.has_point(grid_pos)
	else:
		return ALLY_STAGING_AREA.has_point(grid_pos)


## Return true if the position is in the attacking area as indicated by is_enemy.
func in_attacking_area(grid_pos: Vector2i, is_enemy := false) -> bool:
	if is_enemy:
		return ENEMY_ATTACKING_AREA.has_point(grid_pos)
	else:
		return ALLY_ATTACKING_AREA.has_point(grid_pos)


## Return true if the position is in the defending area as indicated by is_enemy.
func in_defending_area(grid_pos: Vector2i, is_enemy := false) -> bool:
	if is_enemy:
		return ALLY_ATTACKING_AREA.has_point(grid_pos)
	else:
		return ENEMY_ATTACKING_AREA.has_point(grid_pos)


## Return true if the position is in their own castle as indicated by is_enemy.
func in_own_castle(grid_pos: Vector2i, is_enemy := false) -> bool:
	if is_enemy:
		return ENEMY_CASTLE_AREA.has_point(grid_pos)
	else:
		return ALLY_CASTLE_AREA.has_point(grid_pos)


## Return true if the position is in the staging area indicated by is_enemy.
func in_other_castle(grid_pos: Vector2i, is_enemy := false) -> bool:
	if is_enemy:
		return ALLY_CASTLE_AREA.has_point(grid_pos)
	else:
		return ENEMY_CASTLE_AREA.has_point(grid_pos)
