extends Area2D


var grid_position := Vector2i(0, 0)
var is_mouse_inside := false # Is there a native variable for this?
var tooltip_prefab = preload("res://src/ui/tooltip.tscn")

@onready var tooltip_delay: Timer = %TooltipDelay


func _mouse_enter() -> void:
	is_mouse_inside = true
	if(find_parent("Game").get_unit(grid_position)):
		tooltip_delay.start()


func _mouse_exit() -> void:
	is_mouse_inside = false


func _on_tooltip_delay_timeout() -> void:
	var new_tooltip := tooltip_prefab.instantiate()
	find_parent("Game").find_child("CanvasLayer").add_child(new_tooltip)
