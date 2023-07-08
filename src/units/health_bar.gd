@tool
class_name HealthBar
extends Node2D

const WIDTH = 20.0
const THICKNESS = 2.0
const OUTLINE_SIZE = 1.0

const OUTLINE = Rect2(
	-(WIDTH/2 + OUTLINE_SIZE),
	-(THICKNESS/2 + OUTLINE_SIZE),
	(WIDTH + 2 * OUTLINE_SIZE),
	(THICKNESS + 2 * OUTLINE_SIZE)
)


@export_range(0.0, 1.0) var health: float = 1.0


func _draw() -> void:
	draw_rect(OUTLINE, Color.BLACK)
	draw_rect(Rect2(-WIDTH/2, -THICKNESS/2, health * WIDTH, THICKNESS), Color.ORANGE_RED)
