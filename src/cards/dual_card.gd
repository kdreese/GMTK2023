extends Control


@onready var rank_icon: TextureRect = $RankIcon
@onready var attack_label: Label = $AttackLabel
@onready var attack_icon: TextureRect = $AttackIcon
@onready var defense_icon: TextureRect = $DefenseIcon
@onready var defense_label: Label = $DefenseLabel


func initialize(data: DualCardData) -> void:
	rank_icon.texture = Util.rank_to_texture(data.rank)
	attack_label.text = data.attack.name
	attack_icon.texture = data.attack.icon
	defense_label.text = data.defense.name
	defense_icon.texture = data.defense.icon
