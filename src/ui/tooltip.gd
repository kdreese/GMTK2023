extends CenterContainer

const vert_offset = 42.0

@onready var info_text: Label = %InfoText
@onready var damage_amt: Label = %DamageAmt
@onready var health_amt: Label = %HealthAmt
@onready var move_amt: Label = %MoveAmt
@onready var damage_icon: TextureRect = %DamageIcon
@onready var health_icon: TextureRect = %HealthIcon
@onready var move_icon: TextureRect = %MoveIcon


func initialize(unit: Unit) -> void:
	if unit is RangedUnit:
		damage_amt.text = str(unit.attack_damage)
		health_icon.hide()
		health_amt.hide()
		move_icon.hide()
		move_amt.hide()

	elif unit is MeleeUnit:
		damage_amt.text = str(unit.attack_power)
		health_amt.text = str(unit.health)
		move_amt.text = str(unit.speed)

	if not unit.special_effect == "":
		info_text.text = unit.special_effect
	else:
		info_text.hide()

	call_deferred("set_pos", unit)


func set_pos(unit: Unit) -> void:
	var position_offset := Vector2(-100, -100)
	if unit.grid_position.y < 3:
		position_offset.y += vert_offset
	else:
		position_offset.y -= vert_offset - 5
	position = unit.position + position_offset
	position.x = clampf(position.x, -30, 670)
