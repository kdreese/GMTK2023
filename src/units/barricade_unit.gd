class_name BarricadeUnit
extends Unit


@onready var sprite: Sprite2D = %Sprite
@onready var rank_icon: Sprite2D = %RankIcon
@onready var health_bar: ProgressBar = %HealthBar

@onready var hit_barricade_sound: AudioStreamPlayer2D = $HitBarricadeSound


var health: int
var max_health: int


func init(data: BarricadeUnitData, grid_pos: Vector2i, world_pos: Dictionary) -> void:
	grid_position = grid_pos
	grid_to_world_position = world_pos
	special_effect = data.special_effect
	health = data.health
	max_health = health
	if grid_position.y >= 3:
		health_bar.add_theme_stylebox_override("fill", preload("res://src/ui/health_bar_fill_blue.tres"))
	else:
		health_bar.add_theme_stylebox_override("fill", preload("res://src/ui/health_bar_fill_red.tres"))
	update_health_bar()
	sprite.texture = data.icon
	rank_icon.texture = Util.rank_to_texture(data.rank)
	update_position()


func update_health_bar() -> void:
	var value = float(health) / max_health
	health_bar.value = value


func update_position() -> void:
	position = grid_to_world_position[grid_position]


func play_hit_barricade_sound() -> void:
	hit_barricade_sound.play()
