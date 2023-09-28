class_name MeleeUnit
extends Unit


@onready var sprite: Sprite2D = %Sprite
@onready var rank_icon: Sprite2D = %RankIcon
@onready var health_bar: ProgressBar = %HealthBar

@onready var step_sounds: Node2D = $StepSounds
@onready var damage_sound: AudioStreamPlayer2D = $DamageSound


var attack_power: int
var recoil: int
var health: int
var max_health: int
var speed: int


func init(data: MeleeUnitData, grid_pos: Vector2i, world_pos: Dictionary) -> void:
	grid_position = grid_pos
	world_position_dict = world_pos
	special_effect = data.special_effect
	attack_power = data.attack_power
	recoil = data.attack_recoil
	health = data.health
	max_health = health
	speed = data.speed
	if grid_position.y < 3:
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
	position = world_position_dict[grid_position]


func play_step_sound() -> void:
	var i := randi_range(0, step_sounds.get_child_count() - 1)
	step_sounds.get_child(i).play()


func play_damage_sound() -> void:
	damage_sound.play()
