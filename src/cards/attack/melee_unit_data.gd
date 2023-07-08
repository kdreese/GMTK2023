## A data structure for attack cards.
class_name MeleeUnitData
extends CardData


@export var attack_power: int ## The amount of damage this card does each turn.
@export var attack_recoil: int ## The amount of damage this card takes after attacking.
@export var health: int ## The card's max health.
@export var speed: int = 1 ## The number of tiles this unit can move in a turn.
@export_file() var unit ## A path to the unit this card will spawn.
