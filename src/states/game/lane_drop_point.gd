extends Area2D


const Tooltip = preload("res://src/ui/tooltip.tscn")

@export var grid_position := Vector2i(0, 0)

var is_mouse_inside := false # Is there a native variable for this?
var open_tooltip: Control = null

@onready var tooltip_delay: Timer = %TooltipDelay


func _mouse_enter() -> void:
	is_mouse_inside = true
	if open_tooltip == null and find_parent("Game").get_unit(grid_position):
		tooltip_delay.start()


func _mouse_exit() -> void:
	is_mouse_inside = false
	if open_tooltip:
		open_tooltip.queue_free()
		find_parent("Game").find_child("CanvasLayer").remove_child(open_tooltip)
		open_tooltip = null
	tooltip_delay.stop()


func _on_tooltip_delay_timeout() -> void:
	if not is_mouse_inside:
		return
	open_tooltip = Tooltip.instantiate()
	find_parent("Game").find_child("CanvasLayer").add_child(open_tooltip)
	open_tooltip.initialize(find_parent("Game").get_unit(grid_position))
