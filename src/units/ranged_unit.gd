class_name RangedUnit
extends Unit


@onready var sprite: Sprite2D = %Sprite
@onready var rank_icon: Sprite2D = %RankIcon
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound


var attack_range: int = 1
var attack_damage: int = 5
var rank: int = 1


func init(data: RangedUnitData, starting_position: Vector2i, world_pos: Dictionary) -> void:
	card_data = data
	attack_range = data.attack_range
	attack_damage = data.attack_damage
	grid_position = starting_position
	grid_to_world_position = world_pos
	special_effect = data.special_effect
	sprite.texture = data.icon
	rank_icon.texture = Util.rank_to_texture(data.rank)
	rank = data.rank
	update_position()


func update_position() -> void:
	position = grid_to_world_position[grid_position]


func play_shoot_sound() -> void:
	shoot_sound.play()
