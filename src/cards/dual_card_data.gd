class_name DualCardData
extends Resource

@export var attack: AttackCardData
@export var defense: DefenseCardData
@export var rank: int


func _init(att_data: AttackCardData, def_data: DefenseCardData) -> void:
	if att_data.rank != def_data.rank:
		push_warning("Ranks do not match.")
	attack = att_data
	defense = def_data
	rank = att_data.rank
