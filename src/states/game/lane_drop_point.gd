extends Area2D


const Tooltip = preload("res://src/ui/tooltip.tscn")
const ENABLE_COLOR = Color.TRANSPARENT
const DISABLE_COLOR = Color(0.0, 0.0, 0.0, 0.5)

@export var grid_position := Vector2i(0, 0)

var enabled := true ## False if the selected card cannot be placed here.
var is_mouse_inside := false # Is there a native variable for this?
var open_tooltip: Control = null

@onready var tooltip_delay: Timer = %TooltipDelay
@onready var game: Node2D = find_parent("Game")
@onready var overlay: Polygon2D = %Overlay


func _ready() -> void:
	# Set the overlay equal to the hitbox.
	overlay.set_polygon($CollisionPolygon2D.get_polygon())


func _mouse_enter() -> void:
	is_mouse_inside = true
	check_for_start_tooltip()


func _mouse_exit() -> void:
	is_mouse_inside = false
	close_tooltip()


func set_enabled(_enabled: bool) -> void:
	self.enabled = _enabled
	if _enabled:
		overlay.color = ENABLE_COLOR
	else:
		overlay.color = DISABLE_COLOR


func check_for_start_tooltip() -> void:
	if open_tooltip == null and game.get_unit(grid_position) and game.can_display_tooltip:
		tooltip_delay.start()


func close_tooltip() -> void:
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
