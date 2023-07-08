class_name DefenseCardData
extends Resource


@export var name: String ## The name of the card.
@export_multiline var description: String ## A detailed description
@export var icon: Texture2D ## The icon for this card.
@export var rank: int ## The power rank of this card.
@export_file() var effect ## A path to the effect this card will do.
