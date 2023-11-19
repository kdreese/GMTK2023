extends Resource
class_name CardPool
## A pool of cards from which to draw.


# I would do this with a typed dictionary (Dictionary[CardData, int]) instead if I could.
@export var entries: Array[CardPoolEntry] = [] ## The entries in this card pool.


var cards: Array[CardData] = [] ## The flattened list of cards.


## Reset the state of the 'cards' variable. Call this before doing draws.
func reset() -> void:
	cards.clear()
	for entry in entries:
		for _idx in entry.quantity:
			cards.append(entry.card)


## Draw a new card and remove it from the pool.
func draw_card() -> CardData:
	cards.shuffle()
	var card := cards.pop_front() as CardData
	return card
