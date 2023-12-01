extends ColorRect


@onready var card_choices: HBoxContainer = %CardChoices


var cards: Array[DualCardData]
var ranks: Array[int]

var num_cards_offered := 3
var draft_round := 1


func _ready() -> void:
	hide()


func set_ranks(new_ranks: Array) -> void:
	ranks = new_ranks.duplicate()


func select_card_set() -> void:
	cards.clear()
	var rank: int = ranks.pop_front()
	var attack_card_pool := Global.attack_cards[rank] as CardPool
	var defense_card_pool := Global.defense_cards[rank] as CardPool
	attack_card_pool.reset()
	defense_card_pool.reset()
	for i in range(num_cards_offered):
		var attack_card := attack_card_pool.take_card()
		var defense_card := defense_card_pool.take_card()
		cards.append(DualCardData.new(attack_card, defense_card))

	# Display first_set cards
	display_cards()


func display_cards() -> void:
	for card in cards:
		var option := VBoxContainer.new()
		var dual_card := card
		var dual_card_node := preload("res://src/cards/dual_card.tscn").instantiate()
		var full_cards := HBoxContainer.new()
		var attack_card := card.attack
		var attack_card_node := preload("res://src/cards/card_info.tscn").instantiate()
		var defense_card := card.defense
		var defense_card_node := preload("res://src/cards/card_info.tscn").instantiate()
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
		dual_card_node.draggable = false


func select_card(selection: DualCardData) -> void:
	# add the dual card to the player's deck
	Global.deck.append(selection)
	var game: GameScene = find_parent("Game")
	game.play_sound(game.SoundEffect.DRAW)
	for option in card_choices.get_children():
		option.queue_free()
	# display the next set of cards or go to next stage
	if ranks:
		select_card_set()
	else:
		Global.card_replay_moves = Global.card_current_moves
		Global.card_current_moves = {}
		$CenterContainer.hide()
		modulate = Color.TRANSPARENT # Look like we're hiding but prevent the mouse from passing through
		await game.wait_for_timer(Global.animation_speed * 2) # Give time for the sound to play
		get_tree().reload_current_scene()
