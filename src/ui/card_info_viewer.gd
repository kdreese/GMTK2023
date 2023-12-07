extends Panel


@onready var attack_card: Control = $AttackCard
@onready var defense_card: Control = $DefenseCard


func close() -> void:
	self.hide()


func update(attack_data: CardData, defense_data: CardData) -> void:
	if attack_data != null:
		assert(attack_data.card_role == "Attack")
	if defense_data != null:
		assert(defense_data.card_role == "Defense")
	attack_card.initialize(attack_data)
	defense_card.initialize(defense_data)
