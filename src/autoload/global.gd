extends Node


const MAX_VOLUME_DB = -6.0


var animation_speed: float = 0.25
var attack_cards := {}		# Dictionary[int, Array[CardData]]
var defense_cards := {}		# Dictionary[int, Array[CardData]]
var curr_stage: int = 0
var draft_card_ranks_per_stage := {
	1 : [1, 1],
	2 : [1, 2],
	3 : [2, 2],
	4 : [2, 3],
	5 : [3, 3],
	6 : [3, 4],
	7 : [4, 4],
}
var deck: Array[DualCardData] = [
	DualCardData.new(preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), preload("res://src/cards/defense/defense_cards/walls_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/swordsman_1.tres"), preload("res://src/cards/defense/defense_cards/archer_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/cavalier_1.tres"), preload("res://src/cards/defense/defense_cards/archer_1.tres")),
	DualCardData.new(preload("res://src/cards/attack/attack_cards/battering_ram.tres"), preload("res://src/cards/defense/defense_cards/walls_2.tres"))
]
# The next two variables are in the format: Dictionary[turn_number: int, moves: Array[Array[data: CardData, lane: int]]]
var card_replay_moves := {
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
} # The moves played last round, which will be replayed by the enemy this round
var card_current_moves := {} # The moves currently played this round. The lanes are in player POV and need to be shifted


func _ready() -> void:
	var attack_card_strings := DirAccess.get_files_at("res://src/cards/attack/attack_cards/")
	var defense_card_strings := DirAccess.get_files_at("res://src/cards/defense/defense_cards/")

	for attack_card_path in attack_card_strings:
		var attack_card := load("res://src/cards/attack/attack_cards/" + attack_card_path) as CardData
		if not attack_cards.has(attack_card.rank):
			attack_cards[attack_card.rank] = []
		attack_cards[attack_card.rank].append(attack_card)

	for defense_card_path in defense_card_strings:
		var defense_card := load("res://src/cards/defense/defense_cards/" + defense_card_path) as CardData
		if not defense_cards.has(defense_card.rank):
			defense_cards[defense_card.rank] = []
		defense_cards[defense_card.rank].append(defense_card)


func set_music_volume(value: float):
	var music_bus_index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_index, MAX_VOLUME_DB + (20 * log(value) / log(10)))
