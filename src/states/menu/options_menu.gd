extends Control


const ANIMATION_SPEED_STRINGS = ["Very Slow", "Slow", "Normal", "Fast", "Hyperspeed"]


@onready var sound_volume_slider: HSlider = %SoundVolumeSlider
@onready var sound_volume_value: Label = %SoundVolumeValue
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_value: Label = %MusicVolumeValue
@onready var anim_speed_slider: HSlider = %AnimSpeedSlider
@onready var anim_speed_value: Label = %AnimSpeedValue
@onready var fullscreen_button: CheckButton = %FullscreenButton


func _ready() -> void:
	if get_window().mode == Window.MODE_FULLSCREEN:
		fullscreen_button.set_pressed_no_signal(true)
	Global.fullscreen_changed.connect(on_fullscreen_changed)
	var anim_speed_idx: int = Global.config["anim_speed_idx"]
	anim_speed_slider.set_value_no_signal(anim_speed_idx)
	anim_speed_value.text = ANIMATION_SPEED_STRINGS[int(anim_speed_idx)]
	var sound_volume := Global.get_sound_volume()
	sound_volume_slider.set_value_no_signal(sound_volume)
	sound_volume_value.text = "%d" % (sound_volume * 100)
	var music_volume := Global.get_music_volume()
	music_volume_slider.set_value_no_signal(music_volume)
	music_volume_value.text = "%d" % (music_volume * 100)


func on_fullscreen_changed(fullscreen: bool) -> void:
	fullscreen_button.set_pressed_no_signal(fullscreen)


func on_sound_volume_slider_change(value: float) -> void:
	Global.set_sound_volume(value)
	sound_volume_value.text = "%d" % (value * 100)


func on_music_volume_slider_change(value: float) -> void:
	Global.set_music_volume(value)
	music_volume_value.text = "%d" % (value * 100)


func on_anim_speed_slider_change(value: float) -> void:
	var int_value := int(value)
	Global.config["anim_speed_idx"] = int_value
	Global.animation_speed = Global.ANIMATION_SPEEDS[int_value]
	anim_speed_value.text = ANIMATION_SPEED_STRINGS[int_value]


func on_fullscreen_button_toggle(pressed: bool) -> void:
	Global.set_fullscreen(pressed)
