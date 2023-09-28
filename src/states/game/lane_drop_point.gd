extends Area2D


const Tooltip = preload("res://src/ui/tooltip.tscn")

@export var grid_position := Vector2i(0, 0)

var is_mouse_inside := false # Is there a native variable for this?
var open_tooltip: Control = null

@onready var tooltip_delay: Timer = %TooltipDelay
@onready var game: Node2D = find_parent("Game")

func _mouse_enter() -> void:
	is_mouse_inside = true
	if open_tooltip == null and game.get_unit(grid_position):
		tooltip_delay.start()


func _mouse_exit() -> void:
	is_mouse_inside = false
	if open_tooltip:
		open_tooltip.queue_free()
		game.find_child("CanvasLayer").remove_child(open_tooltip)
		open_tooltip = null
	tooltip_delay.stop()


func _on_tooltip_delay_timeout() -> void:
	if not is_mouse_inside or not game.get_unit(grid_position):
		return
	open_tooltip = Tooltip.instantiate()
	game.find_child("CanvasLayer").add_child(open_tooltip)
	open_tooltip.initialize(game.get_unit(grid_position))
