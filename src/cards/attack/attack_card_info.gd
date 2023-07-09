extends Control


@onready var card_name: Label = %Name
@onready var icon: TextureRect = %Icon
@onready var description: Label = %Description
@onready var rank_icon: TextureRect = %RankIcon


func initialize(data: CardData) -> void:
	card_name.text = data.name
	icon.texture = data.icon
	description.text = data.description
	rank_icon.texture = Util.rank_to_texture(data.rank)
