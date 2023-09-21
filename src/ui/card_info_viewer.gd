extends Panel


@onready var attack_card: Control = $AttackCard
@onready var defense_card: Control = $DefenseCard


func close() -> void:
	self.hide()


func update(attack_data: CardData, defense_data: CardData) -> void:
	assert(attack_data.card_role == "Attack")
	assert(defense_data.card_role == "Defense")
	attack_card.initialize(attack_data)
	defense_card.initialize(defense_data)
