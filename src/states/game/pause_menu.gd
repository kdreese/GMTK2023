extends ColorRect


signal resumed


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		resume()
		get_viewport().set_input_as_handled()


func resume() -> void:
	get_tree().paused = false
	hide()
	resumed.emit()


func _on_to_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/states/menu/menu.tscn")


func _on_resume_button_pressed() -> void:
	resume()
