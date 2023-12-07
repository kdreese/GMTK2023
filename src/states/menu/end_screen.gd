extends Control
## Script handling both win and lose end game screens


@onready var endless_count_text: Label = %EndlessCountText


func _ready() -> void:
	if Global.endless_mode:
		endless_count_text.show()
		endless_count_text.text = "You survived to round %d!" % Global.curr_stage
	else:
		endless_count_text.hide()


func to_menu() -> void:
	get_tree().change_scene_to_file.call_deferred("res://src/states/menu/menu.tscn")
