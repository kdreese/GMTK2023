class_name RangedUnit
extends Unit


@onready var sprite: Sprite2D = %Sprite
@onready var rank_icon: Sprite2D = %RankIcon
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound


var attack_range: int = 1
var attack_damage: int = 5


func init(data: RangedUnitData, starting_position: Vector2i) -> void:
	attack_range = data.attack_range
	attack_damage = data.attack_damage
	grid_position = starting_position
	sprite.texture = data.icon
	rank_icon.texture = Util.rank_to_texture(data.rank)
	update_position()


func update_position() -> void:
	if grid_position.y < 3:
		position = Vector2(580, 40) + grid_position.y * Vector2(0, 40)
	else:
		position = Vector2(60, 200) + (grid_position.y - 3) * Vector2(0, 40)


func play_shoot_sound() -> void:
	shoot_sound.play()
