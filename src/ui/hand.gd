# @tool
class_name Hand
extends Control
## A node for displaying the user's hand.


# Signals
## A signal for when a card drag is started.
signal dragged(card: DualCard)

## A signal for when a card is dropped.
signal dropped(card: DualCard)

# Enums


# Constants


# Exported Variables


# Variables
## The list of cards in the hand.
var cards: Array[DualCard] = []


# Onready Variables
## A control defining the extent of the hand.
@onready var bounds: Control = %Bounds


# Signal Handles
## Called when a child of this node is clicked, initiating a drag.
##
## dragged_card is the card that was clicked on.
func _on_card_dragged(dragged_card: Control) -> void:
	for card in cards:
		if card != dragged_card:
			card.draggable = false
	dragged.emit(dragged_card)


## Called when a card is being dragged and the mouse button is released.
##
## card is the card that was dropped.
func _on_card_dropped(card: DualCard) -> void:
	for other_card in cards as Array[DualCard]:
		other_card.draggable = true
	raise_if_mouse_inside(true, card)
	dropped.emit(card)


# Other Functions
## Add a card to the hand.
##
## data is the data structure for the card. This function handles instantiating the scene, giving
## it the right data, and arranging the cards afterwards.
func add_card(data: DualCardData) -> void:
	var new_card := preload("res://src/cards/dual_card.tscn").instantiate()
	add_child(new_card)
	new_card.initialize(data)
	new_card.draggable = false
	new_card.started_drag.connect(_on_card_dragged)
	new_card.dropped_card.connect(_on_card_dropped)
	cards.append(new_card)
	arrange_cards()


## Remove a card from the hand.
##
## card is the node to remove.
func remove_card(card: DualCard) -> void:
	remove_child(card)
	cards.erase(card)
	arrange_cards()
	card.queue_free()


## Set all cards to be either draggable or not, depending on the parameter passed in.
func set_all_draggable(draggable: bool, should_raise := true) -> void:
	for card in cards:
		card.draggable = draggable

	# If we are enabling dragging, check to see if the mouse is on a card, if so activate it.
	if draggable and should_raise:
		raise_if_mouse_inside(false)


## Raise a card if the mouse is inside it.
##
## If instant, and the mouse is inside the dropped card, no animation will be played.
func raise_if_mouse_inside(instant: bool, dropped_card: DualCard = null) -> void:
	for idx in range(len(cards) - 1, -1, -1):
		var card := cards[idx]
		if not card.dragging and card.get_global_rect().has_point(get_global_mouse_position()):
			if instant and card == dropped_card:
				card.raise_instant()
			else:
				card._on_mouse_enter()
			break


## Arrange the cards and display them.
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

	var i := 0
	for card in cards:
		card.position = first_card_position + i * card_spacing
		card.hand_position = card.position
		i += 1
