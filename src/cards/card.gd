extends Control


@onready var card_name: Label = %Name
@onready var icon: TextureRect = %Icon
@onready var description: Label = %Description


func initialize(data: AttackCardData) -> void:
	card_name.text = data.name
	icon.texture = data.icon
	description.text = data.description
