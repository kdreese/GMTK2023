class_name TextBox
extends Control


signal text_finished


@onready var dialog: RichTextLabel = %Dialog
@onready var speaker: PanelContainer = %Speaker
@onready var speaker_text: Label = %SpeakerText
@onready var next_button: Button = %NextButton


var lines: Array[DialogLine]


func play(new_dialog: Dialog) -> void:
	lines = new_dialog.lines
	show()
	display_line()


func display_line() -> void:
	if lines[0].speaker:
		speaker_text.text = lines[0].speaker
		speaker.show()
	else:
		speaker.hide()

	dialog.text = lines[0].text
	lines.pop_front()


func next() -> void:
	if lines:
		display_line()
	else:
		text_finished.emit()
		hide()
