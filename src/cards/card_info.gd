# @tool
class_name CardInfo
extends Node

## Docstring


# Signals


# Enums


# Constants
const MAX_FONT_SIZE = 10


# Exported Variables


# Variables
var data: CardData


# Onready Variables
@onready var background: TextureRect = $Background
@onready var card_name: Label = %Name
@onready var icon: TextureRect = %Icon
@onready var description: Label = %Description
@onready var rank_icon: TextureRect = %RankIcon

# Built-in Functions


# Other Functions
func initialize(_data: CardData) -> void:
	self.data = _data
	card_name.text = data.name
	Util.fit_text(card_name, MAX_FONT_SIZE)

	icon.texture = data.icon
	description.text = data.description
	rank_icon.texture = Util.rank_to_texture(data.rank)
	if data.card_role == "Attack":
		background.texture = preload("res://assets/attack_card.png")
	else:
		background.texture = preload("res://assets/defense_card.png")

	update_icons($Stats)


func update_icons(grid: GridContainer) -> void:
	for node in grid.get_children():
		node.hide()
	if data.info_show_flags & CardData.SHOW_HEALTH_FLAG:
		grid.get_node("HealthIcon").show()
		var label = grid.get_node("HealthLabel") as Label
		label.show()
		var text := data.stat_string_overrides["health"] as String
		if text == "":
			text = str(data.health)
		else:
			label.add_theme_font_size_override("font_size", 6)
		grid.get_node("HealthLabel").text = text
	if data.info_show_flags & CardData.SHOW_MOVEMENT_FLAG:
		grid.get_node("MvmtIcon").show()
		var label := grid.get_node("MvmtLabel") as Label
		label.show()
		var text := data.stat_string_overrides["movement"] as String
		if text == "":
			text = str(data.movement)
		else:
			label.add_theme_font_size_override("font_size", 6)
		grid.get_node("MvmtLabel").text = text
	if data.info_show_flags & CardData.SHOW_DAMAGE_FLAG:
		grid.get_node("AttIcon").show()
		var label := grid.get_node("AttLabel") as Label
		label.show()
		var text := data.stat_string_overrides["damage"] as String
		if text == "":
			text = str(data.damage)
		else:
			label.add_theme_font_size_override("font_size", 6)
		grid.get_node("AttLabel").text = text
	if data.info_show_flags & CardData.SHOW_RANGE_FLAG:
		grid.get_node("RangeIcon").show()
		var label := grid.get_node("RangeLabel") as Label
		label.show()
		var text := data.stat_string_overrides["range"] as String
		if text == "":
			text = str(data.range)
		else:
			label.add_theme_font_size_override("font_size", 6)
		grid.get_node("RangeLabel").text = text
	if data.special:
		grid.get_node("SpecialLabel").show()
		grid.get_node("SpecialIcon").show()


# Subclass Definitions

