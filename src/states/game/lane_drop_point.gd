extends Area2D


@export_range(0, 5) var lane_index := 0

var is_mouse_inside := false # Is there a native variable for this?


func _mouse_enter() -> void:
	is_mouse_inside = true


func _mouse_exit() -> void:
	is_mouse_inside = false
