## A data structure for attack cards.
class_name AttackCardData
extends Resource


@export var name: String ## The name of the card.
@export_multiline var description: String ## A detailed description
@export var icon: Texture2D ## The icon for this card.
@export var rank: int ## The power rank of this card.
@export var attack_power: int ## The amount of damage this card does each turn.
@export var attack_recoil: int ## The amount of damage this card takes after attacking.
@export var health: int ## The card's max health.
@export_file() var unit ## A path the the unit this card will spawn.
