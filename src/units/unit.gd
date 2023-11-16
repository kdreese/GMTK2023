class_name Unit
extends Node2D

var grid_position: Vector2i
var grid_to_world_position : Dictionary # Dictionary[Vector2i, Vector2]
var special_effect: String
var card_data: CardData

# Extra stats to be added to base.
var extra_stats: Dictionary = {}


func commit_die() -> void:
	if card_data.name == "Battering Ram":
		find_parent("Game").remove_battering_ram_buff(self)
	get_parent().remove_child(self)
	queue_free()
