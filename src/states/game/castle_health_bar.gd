class_name CastleHealthBar
extends Control


@onready var health_bar: ProgressBar = $V/HealthBar
@onready var health_label: Label = $V/P/M/HealthText


var max_health: int
var current_health: int


func initialize(init_health: int, red: bool = true) -> void:
	max_health = init_health
	current_health = init_health
	update()


func modify_health(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	update()


func update() -> void:
	var value = float(current_health) / max_health
	health_bar.value = value
	health_label.text = "%d/%d HP" % [current_health, max_health]
