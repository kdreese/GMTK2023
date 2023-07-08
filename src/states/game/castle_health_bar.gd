class_name CastleHealthBar
extends Control


@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var current_health_label: Label = $VBoxContainer/CurrentHealth
@onready var max_health_label: Label = $VBoxContainer/MaxHealth
@onready var fill_stylebox: StyleBoxFlat = preload("res://src/ui/castle_health_bar_fill.tres").duplicate()


var max_health: int
var current_health: int


func initialize(init_health: int, color: Color) -> void:
	max_health = init_health
	current_health = init_health
	fill_stylebox.bg_color = color
	health_bar.add_theme_stylebox_override("fill", fill_stylebox)
	update()


func update() -> void:
	var value = max_health / current_health
	health_bar.value = value
	current_health_label.text = str(current_health)
	max_health_label.text = str(max_health)
