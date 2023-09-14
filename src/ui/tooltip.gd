extends Control


@onready var info_text: Label = %infoText
@onready var damage_amt: Label = %DamageAmt
@onready var health_amt: Label = %HealthAmt
@onready var move_amt: Label = %MoveAmt
@onready var damage_icon: TextureRect = %DamageIcon
@onready var health_icon: TextureRect = %HealthIcon
@onready var move_icon: TextureRect = %MoveIcon


func initialize(unit : Unit) -> void:
	if unit is RangedUnit:
		damage_amt.text = unit.attack_damage
		health_icon.hide()
		health_amt.hide()
		move_icon.hide()
		move_amt.hide()

	elif unit is MeleeUnit:
		damage_amt.text = unit.attack_power
		health_amt.text = unit.health
		move_amt.text = unit.speed
