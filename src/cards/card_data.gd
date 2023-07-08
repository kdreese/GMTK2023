## A data structure for cards.
class_name CardData
extends Resource


@export var name: String ## The name of the card.
@export_multiline var description: String ## A detailed description
@export var icon: Texture2D ## The icon for this card.
@export var rank: int ## The power rank of this card.
@export_enum("Attack", "Defense") var card_role: String ## The role of this card.
@export_file() var effect_script ## A path to the script run by this card.
@export var script_args: Array[String] ## Extra arguments to be passed to the script.
