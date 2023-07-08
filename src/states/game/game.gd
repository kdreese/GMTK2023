extends Node2D


const RED_CASTLE_DOOR = Vector2(160, 240)
const BLUE_CASTLE_DOOR = Vector2(480, 80)

@onready var pause_menu: ColorRect = %PauseMenu
@onready var red_castle_health_bar: CastleHealthBar = $RedCastleHealthBar
@onready var blue_castle_health_bar: CastleHealthBar = $BlueCastleHealthBar
@onready var end_round_button: Button = $EndRoundButton


var enemy_moves: Array[Dictionary]
var cards: Array[Resource]
var num_rounds: int = 0
var red_max_health: int = 150
var blue_max_health: int = 200


func _ready() -> void:
	red_castle_health_bar.initialize(red_max_health, true)
	blue_castle_health_bar.initialize(blue_max_health, false)
	var unit = preload("res://src/units/unit.tscn").instantiate()
	$Units.add_child(unit)
	unit.init(preload("res://src/cards/attack/swordsman_1.tres"), 0)
	unit = preload("res://src/units/unit.tscn").instantiate()
	$Units.add_child(unit)
	unit.init(preload("res://src/cards/attack/swordsman_1.tres"), 3)

	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause()
		get_viewport().set_input_as_handled()


func is_spot_open(grid_position: Vector2i):
	if grid_position.x > 7:
		return false
	for unit in $Units.get_children():
		if unit.grid_position == grid_position:
			return false
	return true


func pause() -> void:
	get_tree().paused = true
	pause_menu.show()


func _on_end_round_button_pressed() -> void:
	end_round_button.disabled = true
	upgrade_defenses()
	instant_defensive_damage()
	perpetual_defensive_damage()
	await offensive_action_sweep()
	place_new_offenses()
	num_rounds += 1
	end_round_button.disabled = false


func upgrade_defenses() -> void:
	pass


func instant_defensive_damage() -> void:
	pass


func perpetual_defensive_damage() -> void:
	# for each defensive square, check if a unit is occupying that square
	# if so, call that unit's defensive_action function
	pass


func offensive_action_sweep() -> void:
	var units = $Units.get_children()
	units.sort_custom(sort_by_attack_order)
	for unit in units:
		var steps_left = unit.speed
		for _idx in range(unit.speed):
			if is_spot_open(unit.grid_position + Vector2i.RIGHT):
				unit.grid_position += Vector2i.RIGHT
				unit.update_position()
				steps_left -= 1
				await get_tree().create_timer(0.5).timeout
		if unit.grid_position.x == 7 and steps_left:
			await melee_attack(unit)
	# for each offensive square, check if a unit is occupying that square
	# if so, call that unit's offensive_action function
	pass


func melee_attack(unit: Unit) -> void:
	if unit.grid_position.y > 2:
		unit.position = RED_CASTLE_DOOR
		await get_tree().create_timer(0.25).timeout
		red_castle_health_bar.current_health -= unit.attack_power
		red_castle_health_bar.update()
	else:
		unit.position = BLUE_CASTLE_DOOR
		await get_tree().create_timer(0.25).timeout
		blue_castle_health_bar.current_health -= unit.attack_power
		blue_castle_health_bar.update()
	unit.health -= unit.recoil
	unit.update_health_bar()
	await get_tree().create_timer(0.25).timeout
	if unit.health <= 0:
		unit.queue_free()
	else:
		unit.update_position()
		await get_tree().create_timer(0.25).timeout


func sort_by_attack_order(a, b) -> bool:
	if b.grid_position.y > a.grid_position.y:
		return true
	elif b.grid_position.y < a.grid_position.y:
		return false
	else:
		if b.grid_position.x > a.grid_position.x:
			return true
		else:
			return false


func place_new_offenses() -> void:
	pass
