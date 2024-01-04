extends Control
## Damage text to be displayed when a unit is hit.


const DAMAGE_COLOR = Color.RED
const HEAL_COLOR = Color.GREEN


@onready var label: Label = $Label


func play(value: int) -> void:
	show()
	label.text = "%+d" % value
	if value > 0:
		label.add_theme_color_override("font_color", HEAL_COLOR)
	else:
		label.add_theme_color_override("font_color", DAMAGE_COLOR)
	$AnimationPlayer.play("fade_away")


func on_anim_finished(_animation: String) -> void:
	hide()
	label.text = ""
