extends Control


@onready var title: Label = $UI/Title
@onready var buttons: VBoxContainer = $UI/Buttons
@onready var fanfare: AudioStreamPlayer = %Fanfare
@onready var background_texture: TextureRect = $Background/BackgroundTexture


func _ready() -> void:
	title.modulate = Color.TRANSPARENT
	buttons.modulate = Color.TRANSPARENT
	set_buttons(true)
	fanfare.play()
	get_tree().create_tween().tween_property(background_texture, "position", Vector2(0, -480), 10.0)
	get_tree().create_timer(7.5).timeout.connect(fade_in_title)
	get_tree().create_timer(10.0).timeout.connect(fade_in_buttons)


func fade_in_title() -> void:
	get_tree().create_tween().tween_property(title, "modulate", Color.WHITE, 1.0)


func fade_in_buttons() -> void:
	get_tree().create_tween().tween_property(buttons, "modulate", Color.WHITE, 1.0)
	get_tree().create_timer(1.0).timeout.connect(set_buttons.bind(false))


func set_buttons(disabled: bool) -> void:
	for button in buttons.get_children():
		button.disabled = disabled


func play() -> void:
	get_tree().change_scene_to_file("res://src/states/game/game.tscn")


func options() -> void:
	pass


func credits() -> void:
	get_tree().change_scene_to_file("res://src/states/menu/credits_menu.tscn")


func quit() -> void:
	get_tree().quit()
