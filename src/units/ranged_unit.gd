extends Node2D


@onready var sprite: Sprite2D = %Sprite
@onready var rank_icon: Sprite2D = %RankIcon


var attack_range: int = 1
var attack_damage: int = 5
var row: int


func init(data: RangedUnitData, chosen_row: int) -> void:
	attack_range = data.attack_range
	attack_damage = data.attack_damage
	row = chosen_row
	sprite.texture = data.icon
	rank_icon.texture = Util.rank_to_texture(data.rank)
	update_position()


func update_position() -> void:
	if row < 3:
		position = Vector2(580, 40) + row * Vector2(0, 40)
	else:
		position = Vector2(60, 200) + (row - 3) * Vector2(0, 40)
