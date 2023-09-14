class_name TextBox
extends Control


signal text_started
signal text_finished


@onready var dialog: RichTextLabel = %Dialog
@onready var speaker: PanelContainer = %Speaker
@onready var speaker_text: Label = %SpeakerText
@onready var next_button: Button = %NextButton
@onready var dialog_sound: AudioStreamPlayer = $DialogSound


var lines: Array[DialogLine]
var active: bool


func play(new_dialog: Dialog) -> void:
	active = true
	lines = new_dialog.lines.duplicate()
	show()
	display_line()
	text_started.emit()


func display_line() -> void:
	if lines[0].speaker:
		speaker_text.text = lines[0].speaker
		speaker.show()
	else:
		speaker.hide()

	dialog_sound.play()

	dialog.text = lines[0].text
	lines.pop_front()


func next() -> void:
	if lines:
		display_line()
	else:
		active = false
		text_finished.emit()
		hide()
