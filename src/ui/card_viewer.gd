extends Control


signal close_requested


const CARDS_PER_ROW := 7


@onready var card_container: VBoxContainer = %CardContainer


func update_cards(cards: Array[DualCardData]) -> void:
	var displayed_cards := cards.duplicate()
	displayed_cards.shuffle()	# TODO: Replace with custom sort
	for num in ceili(displayed_cards.size() / float(CARDS_PER_ROW)):
		var hbox := HBoxContainer.new()
		card_container.add_child(hbox)
	for card in displayed_cards:
		var card_node := preload("res://src/cards/dual_card.tscn").instantiate()
		@warning_ignore("integer_division")
		card_container.get_child(displayed_cards.find(card) / CARDS_PER_ROW).add_child(card_node)
		card_node.initialize(card)
		card_node.draggable = false


func _on_close_button_pressed() -> void:
	close_requested.emit()
	for child in card_container.get_children():
		card_container.remove_child(child)
		child.queue_free()
