extends Control


signal close


const CARDSPERROW := 7.0


@onready var card_container: VBoxContainer = %CardContainer


func update_cards(cards: Array[DualCardData]) -> void:
	var displayed_cards := cards.duplicate()
	displayed_cards.shuffle()	# TODO: Replace with custom sort
	for child in card_container.get_children():
		card_container.remove_child(child)
		child.queue_free()
	for num in ceili(displayed_cards.size() / CARDSPERROW):
		var hbox := HBoxContainer.new()
		card_container.add_child(hbox)
	for card in displayed_cards:
		var card_node := preload("res://src/cards/dual_card.tscn").instantiate()
		card_container.get_child(floori(displayed_cards.find(card) / CARDSPERROW)).add_child(card_node)
		card_node.initialize(card)
		card_node.draggable = false


func _on_close_button_pressed() -> void:
	close.emit()
