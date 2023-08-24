extends Control


const ANIMATION_SPEEDS = [0.5, 0.33, 0.25, 0.2, 0.1]
const ANIMATION_SPEED_STRINGS = ["Slow", "Normal", "Fast", "Very Fast", "Hyperspeed"]


@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_value: Label = %MusicVolumeValue
@onready var anim_speed_slider: HSlider = %AnimSpeedSlider
@onready var anim_speed_value: Label = %AnimSpeedValue
@onready var fullscreen_button: CheckButton = %FullscreenButton


func _ready() -> void:
	if get_window().mode == Window.MODE_FULLSCREEN:
		fullscreen_button.set_pressed_no_signal(true)
	Global.fullscreen_changed.connect(on_fullscreen_changed)
	var anim_speed_idx = Global.config["anim_speed_idx"]
	anim_speed_slider.set_value_no_signal(anim_speed_idx)
	anim_speed_value.text = ANIMATION_SPEED_STRINGS[int(anim_speed_idx)]
	var volume := Global.get_music_volume()
	music_volume_slider.set_value_no_signal(volume)
	music_volume_value.text = "%d" % (volume * 100)


func on_fullscreen_changed(fullscreen: bool) -> void:
	fullscreen_button.set_pressed_no_signal(fullscreen)


func on_music_volume_slider_change(value: float) -> void:
	Global.set_music_volume(value)
	music_volume_value.text = "%d" % (value * 100)


func on_anim_speed_slider_change(value: float):
	Global.config["anim_speed_idx"] = value
	Global.animation_speed = ANIMATION_SPEEDS[int(value)]
	anim_speed_value.text = ANIMATION_SPEED_STRINGS[int(value)]


func on_fullscreen_button_toggle(pressed: bool) -> void:
	Global.set_fullscreen(pressed)
