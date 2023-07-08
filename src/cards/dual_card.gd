extends Control


@onready var rank_icon: TextureRect = $RankIcon
@onready var attack_label: Label = $AttackLabel
@onready var attack_icon: TextureRect = $AttackIcon
@onready var defense_icon: TextureRect = $DefenseIcon
@onready var defense_label: Label = $DefenseLabel


func initialize(data: DualCardData) -> void:
	rank_icon.texture = rank_to_texture(data.rank)
	attack_label.text = data.attack.name
	attack_icon.texture = data.attack.icon
	defense_label.text = data.defense.name
	defense_icon.texture = data.defense.icon


func rank_to_texture(rank: int) -> Texture2D:
	if rank == 1:
		return preload("res://assets/ranks/rank_1.png")
	elif rank == 2:
		return preload("res://assets/ranks/rank_2.png")
	elif rank == 3:
		return preload("res://assets/ranks/rank_3.png")
	elif rank == 4:
		return preload("res://assets/ranks/rank_4.png")
	else:
		push_error("Invalid rank %d" % rank)
		return
