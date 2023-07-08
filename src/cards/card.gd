extends Control


@onready var card_name: Label = %Name
@onready var icon: TextureRect = %Icon
@onready var description: Label = %Description
@onready var rank_icon: TextureRect = %RankIcon


func _ready() -> void:
	initialize(preload("res://src/cards/attack/swordsman_1.tres"))


func initialize(data: AttackCardData) -> void:
	card_name.text = data.name
	icon.texture = data.icon
	description.text = data.description
	rank_icon.texture = rank_to_texture(data.rank)


func rank_to_texture(rank: int) -> Texture2D:
	if rank == 1:
		return preload("res://assets/ranks/rank_1.png")
	elif rank == 2:
		return preload("res://assets/ranks/rank_2.png")
	elif rank == 3:
		return preload("res://assets/ranks/rank_3.png")
	elif rank == 4:
		return preload("res://assets/ranks/rank_4.png")
	else:
		push_error("Invalid rank %d" % rank)
		return
