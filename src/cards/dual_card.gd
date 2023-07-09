extends Control


@onready var rank_icon: TextureRect = $RankIcon
@onready var attack_label: Label = $AttackLabel
@onready var attack_icon: TextureRect = $AttackIcon
@onready var defense_icon: TextureRect = $DefenseIcon
@onready var defense_label: Label = $DefenseLabel


func initialize(data: DualCardData) -> void:
	rank_icon.texture = Util.rank_to_texture(data.rank)
	attack_label.text = data.attack.short_name
	attack_icon.texture = data.attack.icon
	defense_label.text = data.defense.short_name
	defense_icon.texture = data.defense.icon
	update_icons(data.attack, $AttackStats)
	update_icons(data.defense, $DefenseStats)


func update_icons(data: CardData, grid: GridContainer) -> void:
	for node in grid.get_children():
		node.hide()
	if data is MeleeUnitData:
		grid.get_node("HealthLabel").show()
		grid.get_node("HealthLabel").text = str(data.health)
		grid.get_node("HealthIcon").show()
		grid.get_node("AttLabel").show()
		grid.get_node("AttLabel").text = str(data.attack_power)
		grid.get_node("AttIcon").show()
		grid.get_node("MvmtLabel").show()
		grid.get_node("MvmtLabel").text = str(data.speed)
		grid.get_node("MvmtIcon").show()
	elif data is RangedUnitData:
		grid.get_node("AttLabel").show()
		grid.get_node("AttLabel").text = str(data.attack_damage)
		grid.get_node("AttIcon").show()
		grid.get_node("RangeLabel").show()
		grid.get_node("RangeLabel").text = str(data.attack_range)
		grid.get_node("RangeIcon").show()
	else:
		grid.get_node("SpecialLabel").show()
		grid.get_node("SpecialIcon").show()
