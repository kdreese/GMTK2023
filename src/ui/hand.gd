# @tool
class_name Hand
extends Control

## A node for displaying the user's hand.


# Signals
signal dropped(DualCard)

# Enums


# Constants


# Exported Variables


# Variables
var cards: Array[DualCard] = []

# Onready Variables
@onready var bounds: Control = %Bounds


# Built-in Functions
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_card_dragged(dragged_card: Control) -> void:
	for card in cards:
		if card != dragged_card:
			card.draggable = false


func _on_card_dropped(card: DualCard) -> void:
	for other_card in cards as Array[DualCard]:
		other_card.draggable = true
	dropped.emit(card)


func add_card(data: DualCardData) -> void:
	var new_card := preload("res://src/cards/dual_card.tscn").instantiate()
	add_child(new_card)
	new_card.initialize(data)
	new_card.draggable = false
	new_card.started_drag.connect(_on_card_dragged)
	new_card.dropped_card.connect(_on_card_dropped)
	cards.append(new_card)
	arrange_cards()


func remove_card(card: DualCard) -> void:
	remove_child(card)
	arrange_cards()
	card.queue_free()
	cards.erase(card)


func set_all_draggable(draggable: bool) -> void:
	for card in cards:
		card.draggable = draggable


func arrange_cards() -> void:
	if len(cards) == 0:
		return

	var card_width := cards[0].size.x
	var buffer := 10 # Pixels of space between cards.

	var card_spacing: Vector2
	var total_width: float

	if len(cards) * (card_width + buffer) < bounds.size.x:
		# We have enough space to display all cards without overlapping.
		card_spacing = (card_width + buffer) * Vector2.RIGHT
		total_width = len(cards) * (card_width + buffer) - buffer
	else:
		# We must overlap. Set the overlap to a minimum value so that it looks okay.
		var max_card_spacing := (bounds.size.x - card_width) / len(cards)
		card_spacing = min(max_card_spacing, card_width - buffer) * Vector2.RIGHT
		total_width = card_width + (len(cards) - 1) * card_spacing.x

	var center_of_hand := bounds.position + Vector2(bounds.size.x / 2.0, 0.0)
	var first_card_position := center_of_hand - total_width / 2.0 * Vector2.RIGHT

	var i = 0
	for card in cards:
		card.position = first_card_position + i * card_spacing
		card.hand_position = card.position
		i += 1




