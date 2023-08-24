extends Node


signal fullscreen_changed


const CONFIG_PATH := "user://config.cfg"

const DEFAULT_CONFIG := {
	"music_volume": 1.0,
	"anim_speed_idx": 1
}

const MAX_VOLUME_DB = -6.0
const FIRST_REPLAY_MOVES = {
	0: [
		[preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), 1],
	],
	2: [
		[preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), 2],
	],
	4: [
		[preload("res://src/cards/defense/defense_cards/archer_1.tres"), 4],
	],
	6: [
		[preload("res://src/cards/defense/defense_cards/walls_1.tres"), 3],
	],
	8: [
		[preload("res://src/cards/defense/defense_cards/archer_1.tres"), 3],
		[preload("res://src/cards/attack/attack_cards/cavalier_1.tres"), 0]
	],
	10: [
		[preload("res://src/cards/defense/defense_cards/archer_1.tres"), 5]
	]
}


var config := DEFAULT_CONFIG.duplicate()

var animation_speed: float = 0.25
var attack_cards := {}		# Dictionary[int, Array[CardData]]
var defense_cards := {}		# Dictionary[int, Array[CardData]]
var curr_stage: int = 0
var draft_card_ranks_per_stage := {
	1 : [1, 2],
	2 : [2, 2],
	3 : [2, 3],
	4 : [3, 3],
	5 : [3, 3],
}
var deck: Array[DualCardData] = [
	DualCardData.new(preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), preload("res://src/cards/defense/defense_cards/walls_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), preload("res://src/cards/defense/defense_cards/archer_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/cavalier_1.tres"), preload("res://src/cards/defense/defense_cards/archer_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), preload("res://src/cards/defense/defense_cards/walls_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/cavalier_1.tres"), preload("res://src/cards/defense/defense_cards/oil_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/cavalier_1.tres"), preload("res://src/cards/defense/defense_cards/archer_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), preload("res://src/cards/defense/defense_cards/oil_1.tres")),
]
# The next two variables are in the format: Dictionary[turn_number: int, moves: Array[Array[data: CardData, lane: int]]]
var card_replay_moves := FIRST_REPLAY_MOVES # The moves played last round, which will be replayed by the enemy this round
var card_current_moves := {} # The moves currently played this round. The lanes are in player POV and need to be shifted

var endless_mode := false

var current_music_volume := 0.5

# When the user quits the game, save the game before the engine fully quits
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_config()
		get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		# If we're not currently in fullscreen, change to fullscreen. If we are, change back.
		set_fullscreen(get_window().mode != Window.MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()


func _ready() -> void:
	#var attack_card_strings := DirAccess.get_files_at("res://src/cards/attack/attack_cards/")
	#var defense_card_strings := DirAccess.get_files_at("res://src/cards/defense/defense_cards/")
	load_config()
	attack_cards = {
		1: [preload("res://src/cards/attack/attack_cards/cavalier_1.tres"), preload("res://src/cards/attack/attack_cards/swordsman_1.tres")],
		2: [preload("res://src/cards/attack/attack_cards/cavalier_2.tres"), preload("res://src/cards/attack/attack_cards/swordsman_2.tres"), preload("res://src/cards/attack/attack_cards/battering_ram.tres")],
		3: [preload("res://src/cards/attack/attack_cards/cavalier_3.tres"), preload("res://src/cards/attack/attack_cards/swordsman_3.tres")]
	}

	defense_cards = {
		1: [preload("res://src/cards/defense/defense_cards/archer_1.tres"), preload("res://src/cards/defense/defense_cards/oil_1.tres"), preload("res://src/cards/defense/defense_cards/walls_1.tres")],
		2: [preload("res://src/cards/defense/defense_cards/archer_2.tres"), preload("res://src/cards/defense/defense_cards/oil_2.tres"), preload("res://src/cards/defense/defense_cards/walls_2.tres")],
		3: [preload("res://src/cards/defense/defense_cards/archer_3.tres"), preload("res://src/cards/defense/defense_cards/oil_3.tres"), preload("res://src/cards/defense/defense_cards/walls_3.tres")],
	}
#	for attack_card_path in attack_card_strings:
#		var attack_card := load("res://src/cards/attack/attack_cards/" + attack_card_path) as CardData
#		if not attack_cards.has(attack_card.rank):
#			attack_cards[attack_card.rank] = []
#		attack_cards[attack_card.rank].append(attack_card)
#
#	for defense_card_path in defense_card_strings:
#		var defense_card := load("res://src/cards/defense/defense_cards/" + defense_card_path) as CardData
#		if not defense_cards.has(defense_card.rank):
#			defense_cards[defense_card.rank] = []
#		defense_cards[defense_card.rank].append(defense_card)


func save_config() -> void:
	var config_file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if not config_file:
		push_error("Could not open config file for writing!")
		return

	if get_window().mode == Window.MODE_FULLSCREEN:
		config["fullscreen"] = true
	else:
		config["fullscreen"] = false
		config["window_size"] = get_window().size

	config_file.store_var(config)
	config_file.close()


func load_config() -> void:
	var config_file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var open_error := FileAccess.get_open_error()
	if open_error == ERR_FILE_NOT_FOUND:
		print("No config file found, using default settings")
		return
	elif open_error:
		push_warning("Could not open config file for reading! Using default settings")
		return

	var new_config_variant = config_file.get_var()
	config_file.close()

	if typeof(new_config_variant) != TYPE_DICTIONARY:
		push_warning("Config file was corrupted! Using default settings")
		return
	var new_config := new_config_variant as Dictionary

	config = new_config.duplicate()

	# Set the size of the window and center it.
	if "window_size" in config:
		var raw_size := config["window_size"] as Vector2i
		var fixed_size: Vector2i
		if 4 * raw_size.x > 3 * raw_size.y:
			# Wider than it is supposed to be, use the height as the guide.
			fixed_size = Vector2i(snapped(raw_size.y, 3) * 4 / 3, snapped(raw_size.y, 3))
		else:
			# Taller than it is supposed to be, use the width as the guide.
			fixed_size = Vector2i(snapped(raw_size.x, 4), snapped(raw_size.x, 4) * 3 / 4)
		get_window().size = fixed_size
		var screen_id := get_window().current_screen
		var screen_center := DisplayServer.screen_get_position(screen_id) \
				+ DisplayServer.screen_get_size(screen_id) / 2
		get_window().position = screen_center - fixed_size / 2

	if config.get("fullscreen", false):
		# If we're in fullscreen, change the mode.
		get_window().mode = Window.MODE_FULLSCREEN

	update_music_volume()


func set_fullscreen(fullscreen: bool) -> void:
	if fullscreen:
		# Save the window size
		Global.config["window_size"] = get_window().size
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = Global.config["window_size"]
	fullscreen_changed.emit(fullscreen)


func get_music_volume() -> float:
	return config["music_volume"]


func set_music_volume(value: float):
	config["music_volume"] = value
	update_music_volume()


func update_music_volume():
	var music_bus_index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_index, MAX_VOLUME_DB + (20 * log(config["music_volume"]) / log(10)))
