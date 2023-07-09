extends ColorRect


@onready var card_choices: HBoxContainer = %CardChoices


var first_attack_set: Array[CardData]
var first_ranged_set: Array[CardData]
var first_set: Array[DualCardData]
var second_attack_set: Array[CardData]
var second_ranged_set: Array[CardData]
var second_set: Array[DualCardData]

var num_cards_offered := 3
var draft_round := 1


func _ready() -> void:
	hide()


func select_card_set(first_rank: int, second_rank: int) -> void:
	# Select three random attack/defense card pairs with the same rank as first_rank
	# Select three random attack/defense card pairs with the same rank as second_rank
	for i in range(num_cards_offered):
		first_attack_set.append(Global.attack_cards[first_rank].pick_random())
		first_ranged_set.append(Global.defense_cards[first_rank].pick_random())
		first_set.append(DualCardData.new(first_attack_set[i], first_ranged_set[i]))
		second_attack_set.append(Global.attack_cards[second_rank].pick_random())
		second_ranged_set.append(Global.defense_cards[second_rank].pick_random())
		second_set.append(DualCardData.new(second_attack_set[i], second_ranged_set[i]))

	# Display first_set cards
	display_cards(first_set)


func display_cards(cards : Array[DualCardData]) -> void:
	for card in cards:
		var option := VBoxContainer.new()
		var dual_card := card
		var dual_card_node := preload("res://src/cards/dual_card.tscn").instantiate()
		var full_cards := HBoxContainer.new()
		var attack_card := card.attack
		var attack_card_node := preload("res://src/cards/attack/attack_card_info.tscn").instantiate()
		var defense_card := card.defense
		var defense_card_node := preload("res://src/cards/defense/defense_card_info.tscn").instantiate()
		var select_button := Button.new()
		select_button.pressed.connect(self.select_card.bind(dual_card))
		select_button.text = "Take Card"
		full_cards.add_child(attack_card_node)
		full_cards.add_child(defense_card_node)
		option.add_child(dual_card_node)
		option.add_child(full_cards)
		option.add_child(select_button)
		card_choices.add_child(option)
		attack_card_node.initialize(attack_card)
		defense_card_node.initialize(defense_card)
		dual_card_node.initialize(dual_card)


func select_card(selection: DualCardData) -> void:
	# add the dual card to the player's deck
	Global.deck.append(selection)
	for option in card_choices.get_children():
		option.queue_free()
	# display the next set of cards or go to next stage
	if draft_round == 1:
		display_cards(second_set)
		draft_round += 1
	elif draft_round == 2:
		draft_round == 1
		get_tree().reload_current_scene()
