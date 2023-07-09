extends Node


const MAX_VOLUME_DB = -6.0


var animation_speed: float = 0.25


func set_music_volume(value: float):
	var music_bus_index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_index, MAX_VOLUME_DB + (20 * log(value) / log(10)))
