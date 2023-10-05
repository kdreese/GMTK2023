# @tool
class_name CardInfo
extends Node

## Docstring


# Signals


# Enums


# Constants


# Exported Variables


# Variables


# Onready Variables
@onready var background: TextureRect = $Background
@onready var card_name: Label = %Name
@onready var icon: TextureRect = %Icon
@onready var description: Label = %Description
@onready var rank_icon: TextureRect = %RankIcon

# Built-in Functions


# Other Functions
func initialize(data: CardData) -> void:
	card_name.text = data.name
	icon.texture = data.icon
	description.text = data.description
	rank_icon.texture = Util.rank_to_texture(data.rank)
	if data.card_role == "Attack":
		background.texture = preload("res://assets/attack_card.png")
	else:
		background.texture = preload("res://assets/defense_card.png")

	update_icons(data, $Stats)


func update_icons(data: CardData, grid: GridContainer) -> void:
	for node in grid.get_children():
		node.hide()
	if data is MeleeUnitData:
		grid.get_node("HealthLabel").show()
		grid.get_node("HealthLabel").text = str(data.health)
		grid.get_node("HealthIcon").show()
		grid.get_node("AttLabel").show()
		grid.get_node("AttLabel").text = str(data.attack_power)
		grid.get_node("AttIcon").show()
		grid.get_node("MvmtLabel").show()
		grid.get_node("MvmtLabel").text = str(data.speed)
		grid.get_node("MvmtIcon").show()
	elif data is RangedUnitData:
		grid.get_node("AttLabel").show()
		grid.get_node("AttLabel").text = str(data.attack_damage)
		grid.get_node("AttIcon").show()
		grid.get_node("RangeLabel").show()
		grid.get_node("RangeLabel").text = str(data.attack_range)
		grid.get_node("RangeIcon").show()
	else:
		grid.get_node("SpecialLabel").show()
		grid.get_node("SpecialIcon").show()


# Subclass Definitions

