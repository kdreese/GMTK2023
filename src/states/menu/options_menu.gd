extends Control


const ANIMATION_SPEEDS = [0.5, 0.33, 0.25, 0.2, 0.1]
const ANIMATION_SPEED_STRINGS = ["Slow", "Normal", "Fast", "Very Fast", "Hyperspeed"]

@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_value: Label = %MusicVolumeValue
@onready var anim_speed_slider: HSlider = %AnimSpeedSlider
@onready var anim_speed_value: Label = %AnimSpeedValue


func on_music_volume_slider_change(value: float) -> void:
	Global.set_music_volume(value)
	music_volume_value.text = "%d" % (value * 100)


func on_anim_speed_slider_change(value: float):
	Global.animation_speed = ANIMATION_SPEEDS[int(value)]
	anim_speed_value.text = ANIMATION_SPEED_STRINGS[int(value)]
