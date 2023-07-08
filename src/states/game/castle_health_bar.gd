class_name CastleHealthBar
extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var current_health_label: Label = $CurrentHealth
@onready var max_health_label: Label = $MaxHealth
@onready var red_fill_stylebox: StyleBoxFlat = preload("res://src/ui/health_bar_fill_red.tres")
@onready var blue_fill_stylebox: StyleBoxFlat = preload("res://src/ui/health_bar_fill_blue.tres")


var max_health: int
var current_health: int


func initialize(init_health: int, red: bool = true) -> void:
	max_health = init_health
	current_health = init_health
	if red:
		health_bar.add_theme_stylebox_override("fill", red_fill_stylebox)
		current_health_label.add_theme_color_override("font_color", red_fill_stylebox.bg_color)
		max_health_label.add_theme_color_override("font_color", red_fill_stylebox.bg_color)
	else:
		health_bar.add_theme_stylebox_override("fill", blue_fill_stylebox)
		current_health_label.add_theme_color_override("font_color", blue_fill_stylebox.bg_color)
		max_health_label.add_theme_color_override("font_color", blue_fill_stylebox.bg_color)
	update()


func update() -> void:
	var value = float(current_health) / max_health
	health_bar.value = value
	current_health_label.text = str(current_health)
	max_health_label.text = str(max_health)
