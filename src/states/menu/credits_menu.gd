extends Control


var main_licenses := [
	["Godot Engine", Engine.get_license_text()],
	["CAT Engravers Font", FileAccess.get_file_as_string("res://assets/fonts/engravers/Open Font License.txt")],
	["Bailleul Roman Font", FileAccess.get_file_as_string("res://assets/fonts/bailleul_roman/LICENSE.txt")],
]

@onready var licenses_label: RichTextLabel = %LicensesRichLabel


func _ready() -> void:
	licenses_label.text = generate_license_bbcode_text()


func generate_license_bbcode_text() -> String:
	var text := "[center][font_size=36][b]Licenses[/b][/font_size][/center]"

	for license in main_licenses:
		text += "\n\n[center][font_size=20][b]" + license[0].strip_edges() + "[/b][/font_size][/center]\n\n"
		text += "[font_size=13]" + license[1] + "[/font_size]"

	text += "\n\n[center][font_size=26][b]All Licenses[/b][/font_size][/center]"

	# These engine license/copyright functions are not incredibly obvious how to usefully extract information from.
	# This is similar to how it's done in the "About Godot" -> "Third-party Licenses" -> "All Components" screen
	for info in Engine.get_copyright_info():
		text += "\n\n[center][font_size=18][b]" + info.name + "[/b][/font_size][/center]\n"
		for part in info.parts:
			for copyright in part.copyright:
				text += "\n(c) " + copyright
			text += "\nLicense: " + part.license

	var engine_licenses := Engine.get_license_info()
	for license in engine_licenses:
		text += "\n\n[center][font_size=18][b]" + license + "[/b][/font_size][/center]\n\n"
		text += engine_licenses[license]

	return text
