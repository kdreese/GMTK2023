extends Node2D


const RED_CASTLE_DOOR = Vector2(160, 240)
const BLUE_CASTLE_DOOR = Vector2(480, 80)


@onready var pause_menu: ColorRect = %PauseMenu
@onready var card_drafting: ColorRect = %CardDrafting
@onready var options_menu: Control = %OptionsMenu
@onready var red_castle_health_bar: CastleHealthBar = $RedCastleHealthBar
@onready var blue_castle_health_bar: CastleHealthBar = $BlueCastleHealthBar
@onready var card_nodes: Node = $Cards
@onready var end_round_button: Button = $EndRoundButton
@onready var text_box: TextBox = %TextBox

@onready var lane_drops: Array[Area2D] = [
	$AttackDropPoints/Lane0, $AttackDropPoints/Lane1, $AttackDropPoints/Lane2,
	$DefenseDropPoints/Lane3, $DefenseDropPoints/Lane4, $DefenseDropPoints/Lane5,
]


var enemy_moves: Array[Dictionary]
var cards: Array[Resource]
var curr_round: int = 0
var red_max_health: int = 150
var blue_max_health: int = 200

var put_down_this_turn := [false, false, false] # In the attacking lanes, have we put something down this turn yet?


func _ready() -> void:
	options_menu.get_node("%BackButton").pressed.connect(hide_options)
	red_castle_health_bar.initialize(red_max_health, true)
	blue_castle_health_bar.initialize(blue_max_health, false)

	var DualCard := preload("res://src/cards/dual_card.tscn")
	var base_position := get_viewport_rect().size
	base_position.x = base_position.x / 2.0 - 39.0
	base_position.y -= 150.0

	for i in range(3):
		var card := DualCard.instantiate()
		$Cards.add_child(card)
		card.initialize(DualCardData.new(
			preload("res://src/cards/attack/swordsman_1.tres"), preload("res://src/cards/defense/archer_1.tres")
		))
		card.dropped_card.connect(self._on_card_dropped)
	arrange_cards()

	text_box.play(preload("res://assets/dialog/dialog_1.tres"))

	Global.curr_stage += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause()
		get_viewport().set_input_as_handled()


func is_spot_open(grid_position: Vector2i):
	if grid_position.x > 7:
		return false
	for unit in $Units/Melee.get_children():
		if unit.grid_position == grid_position:
			return false
	return true


func get_unit(grid_position: Vector2i) -> Unit:
	for unit in $Units/Melee.get_children():
		if unit.grid_position == grid_position:
			return unit
	return null


func pause() -> void:
	get_tree().paused = true
	pause_menu.show()
	text_box.hide()


func resume() -> void:
	if text_box.lines:
		text_box.show()


func show_options() -> void:
	pause_menu.hide()
	options_menu.show()


func hide_options() -> void:
	options_menu.hide()
	pause_menu.show()


func _on_end_round_button_pressed() -> void:
	end_round_button.disabled = true
	upgrade_defenses()
	await instant_defensive_damage()
	perpetual_defensive_damage()
	await offensive_action_sweep()
	place_new_offenses()
	curr_round += 1
	end_round_button.disabled = false
	put_down_this_turn = [false, false, false]


func _on_card_dropped(card: Control) -> void:
	var found := -1
	for drop in lane_drops:
		if drop.is_mouse_inside:
			found = drop.lane_index
			break
	if found < 0:
		return
	if found < 3 and put_down_this_turn[found]:
		return # Don't want to waste an attacking unit by overriding it before it can go
	# We have a thing to put down! Let's do it
	var unit_data: CardData
	if found < 3:
		unit_data = card.card_data.attack
		put_down_this_turn[found] = true
	else:
		unit_data = card.card_data.defense
	card_nodes.remove_child(card)
	arrange_cards()
	card.queue_free()
	# TODO: Use unit_data script to do something


func upgrade_defenses() -> void:
	pass


func instant_defensive_damage() -> void:
	var units := $Units/Ranged.get_children()
	units.sort_custom(ranged_attack_order)
	for unit in units:
		# Search for the closest non-empty square within the range.
		var target: Node = null
		for x_pos in range(7, 7 - unit.attack_range, -1):
			target = get_unit(Vector2i(x_pos, unit.row))
			if target != null:
				break

		if target == null:
			continue

		# Move the archer forward, slightly.
		var position_offset := Vector2(10.0, 0.0)
		if unit.row < 3:
			position_offset *= -1.0
		unit.position += position_offset
		await get_tree().create_timer(Global.animation_speed).timeout
		# Do the attack.
		target.health -= unit.attack_damage
		target.update_health_bar()
		await get_tree().create_timer(Global.animation_speed).timeout
		# Kill the target, if necessary.
		if target.health < 0:
			target.queue_free()
			await get_tree().create_timer(Global.animation_speed).timeout
		# Move the archer back.
		unit.update_position()
		await get_tree().create_timer(Global.animation_speed).timeout


func perpetual_defensive_damage() -> void:
	# for each defensive square, check if a unit is occupying that square
	# if so, call that unit's defensive_action function
	pass


func offensive_action_sweep() -> void:
	var units := $Units/Melee.get_children()
	units.sort_custom(melee_attack_order)
	for unit in units:
		var steps_left = unit.speed
		for _idx in range(unit.speed):
			if is_spot_open(unit.grid_position + Vector2i.RIGHT):
				unit.grid_position += Vector2i.RIGHT
				unit.update_position()
				steps_left -= 1
				await get_tree().create_timer(Global.animation_speed).timeout
		if unit.grid_position.x == 7 and steps_left:
			await melee_attack(unit)
			check_for_end_condition()
	# for each offensive square, check if a unit is occupying that square
	# if so, call that unit's offensive_action function


func melee_attack(unit: Unit) -> void:
	if unit.grid_position.y > 2:
		unit.position = RED_CASTLE_DOOR
		await get_tree().create_timer(Global.animation_speed).timeout
		red_castle_health_bar.current_health -= unit.attack_power
		red_castle_health_bar.update()
	else:
		unit.position = BLUE_CASTLE_DOOR
		await get_tree().create_timer(Global.animation_speed).timeout
		blue_castle_health_bar.current_health -= unit.attack_power
		blue_castle_health_bar.update()
	unit.health -= unit.recoil
	unit.update_health_bar()
	await get_tree().create_timer(Global.animation_speed).timeout
	if unit.health <= 0:
		unit.queue_free()
	else:
		unit.update_position()
		await get_tree().create_timer(Global.animation_speed).timeout


func melee_attack_order(a, b) -> bool:
	if b.grid_position.y > a.grid_position.y:
		return true
	elif b.grid_position.y < a.grid_position.y:
		return false
	else:
		if b.grid_position.x > a.grid_position.x:
			return true
		else:
			return false


func ranged_attack_order(a, b) -> bool:
	if b.row > a.row:
		return false
	else:
		return true


func place_new_offenses() -> void:
	pass


func check_for_end_condition() -> void:
	if blue_castle_health_bar.current_health <= 0:
		end_round_button.hide()
		card_drafting.select_card_set(Global.draft_card_ranks_per_stage[Global.curr_stage][0],\
				Global.draft_card_ranks_per_stage[Global.curr_stage][1])
		card_drafting.show()
	elif red_castle_health_bar.current_health <= 0:
		pass	# Game over screen


func arrange_cards() -> void:
	var num_cards := card_nodes.get_child_count()
	var base_position := get_viewport_rect().size
	base_position.x = base_position.x / 2 - 39 # Magic number 39 is half the width of scaled DualCard
	base_position.y -= 150
	var card_spacing := 84
	base_position.x -= (num_cards - 1) * card_spacing / 2.0

	for i in range(num_cards):
		var card: Control = card_nodes.get_child(i)
		card.position = base_position
		card.position.x += i * card_spacing
		card.hand_position = card.position
