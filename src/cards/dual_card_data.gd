class_name DualCardData
extends Resource


@export var attack: CardData
@export var defense: CardData
@export var rank: int


func _init(att_data: CardData, def_data: CardData) -> void:
	if att_data.rank != def_data.rank:
		push_warning("Ranks do not match.")
	if att_data.card_role != "Attack":
		push_warning("Attack card does not have attack role.")
	if def_data.card_role != "Defense":
		push_warning("Defense card does not have defense role.")
	attack = att_data
	defense = def_data
	rank = att_data.rank
