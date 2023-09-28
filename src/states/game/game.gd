extends Node2D


signal turn_finished


const MAX_CARDS_IN_HAND = 7
const ROUND_HEALTHS = [
	[20, 30],
	[25, 40],
	[30, 50],
	[40, 60],
	[50, 75]
]
const COPY_ROUND_DOWNTIME = 3


@onready var pause_menu: ColorRect = %PauseMenu
@onready var card_drafting: ColorRect = %CardDrafting
@onready var options_menu: Control = %OptionsMenu
@onready var blue_castle_health_bar: CastleHealthBar = $BlueCastleHealthBar
@onready var red_castle_health_bar: CastleHealthBar = $RedCastleHealthBar
@onready var endless_round_panel: PanelContainer = %EndlessRoundPanel
@onready var endless_round_text: Label = %EndlessRoundText
@onready var end_round_button: Button = %EndRoundButton
@onready var view_deck_button: Button = %ViewDeckButton
@onready var view_discard_button: Button = %ViewDiscardButton
@onready var text_box: TextBox = %TextBox
@onready var card_info_viewer: Panel = %CardInfoViewer
@onready var enemy_attack_card: Control = $EnemyAttackCard
@onready var enemy_defense_card: Control = $EnemyDefenseCard
@onready var card_viewer: Control = %CardViewer
@onready var hand_bounds: Control = %HandBounds
@onready var hand: Hand = %Hand

@onready var drop_points: Node2D = %DropPoints
@onready var blue_castle_door: Vector2 = $DefenseBridgePoint.position
@onready var red_castle_door: Vector2 = $AttackBridgePoint.position

@onready var win_sound: AudioStreamPlayer = $WinSound
@onready var draw_sound: AudioStreamPlayer = $DrawSound


var grid_to_world_pos: Dictionary # Dictionary[Vector2i, Vector2]
var enemy_moves: Array[Dictionary]
var deck: Array[DualCardData]
var discard: Array[DualCardData]
var curr_round: int = 0
var red_max_health: int = 30
var blue_max_health: int = 50

var game_over := false


func _ready() -> void:
	text_box.lines.clear()
	options_menu.get_node("%BackButton").pressed.connect(hide_options)
	text_box.text_finished.connect(on_text_finish)
	text_box.text_started.connect(on_text_start)
	card_viewer.close_requested.connect(close_card_viewer)
	var blue_health: int
	var red_health: int
	var rh_size := ROUND_HEALTHS.size()
	if Global.curr_stage >= rh_size:
		var blue_diff: int = ROUND_HEALTHS[rh_size - 1][0] - ROUND_HEALTHS[rh_size - 2][0]
		var red_diff: int = ROUND_HEALTHS[rh_size - 1][1] - ROUND_HEALTHS[rh_size - 2][1]
		blue_health = ROUND_HEALTHS[rh_size - 1][0] + (Global.curr_stage + 1 - rh_size) * blue_diff
		red_health = ROUND_HEALTHS[rh_size - 1][1] + (Global.curr_stage + 1 - rh_size) * red_diff
	else:
		blue_health = ROUND_HEALTHS[Global.curr_stage][0]
		red_health = ROUND_HEALTHS[Global.curr_stage][1]
	blue_castle_health_bar.initialize(blue_health)
	red_castle_health_bar.initialize(red_health)
	card_info_viewer.hide()
	curr_round = 0

	for point in drop_points.get_children():
		grid_to_world_pos[point.grid_position] = point.global_position

	deck = Global.deck.duplicate()

	if Global.curr_stage == 0:
		Global.card_replay_moves = Global.FIRST_REPLAY_MOVES

	if Global.endless_mode:
		endless_round_panel.show()
		endless_round_text.text = "Round %d" % (Global.curr_stage + 1) # +1 cuz that doesn't happen until after
	else:
		endless_round_panel.hide()

	if not Global.endless_mode and Global.curr_stage == 0:
		end_round_button.disabled = true
		await draw_cards(1)
		text_box.play(preload("res://assets/dialog/dialog_1.tres"))
		await text_box.text_finished
		%OffenseMask.show()
		while len(hand.cards) > 0:
			await hand.dropped
		%OffenseMask.hide()
		text_box.play(preload("res://assets/dialog/dialog_2.tres"))
		await text_box.text_finished
		end_round_button.disabled = false
		await turn_finished
		end_round_button.disabled = true
		text_box.play(preload("res://assets/dialog/dialog_3.tres"))
		await text_box.text_finished
		%DefenseMask.show()
		while len(hand.cards) > 0:
			await hand.dropped
		%DefenseMask.hide()
		text_box.play(preload("res://assets/dialog/dialog_3_5.tres"))
		await text_box.text_finished
		end_round_button.disabled = false
		await turn_finished
		text_box.play(preload("res://assets/dialog/dialog_4.tres"))
		await text_box.text_finished
		await turn_finished
		end_round_button.disabled = true
		await draw_cards(2)
		text_box.play(preload("res://assets/dialog/dialog_5.tres"))
		await text_box.text_finished
		end_round_button.disabled = false
	else:
		deck.shuffle()
		await draw_cards(3)

	if not Global.endless_mode and Global.curr_stage == 1:
		text_box.play(preload("res://assets/dialog/dialog_7.tres"))
		await text_box.text_finished

	Global.curr_stage += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause(pause_menu)
		get_viewport().set_input_as_handled()


func wait_for_timer(time: float) -> void:
	await get_tree().create_timer(time, false).timeout


func is_spot_open(grid_position: Vector2i):
	if grid_position.x > 7:
		return false
	for unit in $Units/Melee.get_children():
		if unit.grid_position == grid_position:
			return false
	return true


func get_unit(grid_position: Vector2i) -> Unit:
	for unit in $Units/Melee.get_children() + $Units/Ranged.get_children():
		if not unit.is_queued_for_deletion() and unit.grid_position == grid_position:
			return unit
	return null


func pause(menu: Node) -> void:
	get_tree().paused = true
	menu.show()
	text_box.hide()


func resume() -> void:
	get_tree().paused = false
	if text_box.active:
		text_box.show()


func show_options() -> void:
	pause_menu.hide()
	options_menu.show()


func hide_options() -> void:
	options_menu.hide()
	pause_menu.show()


func on_text_start() -> void:
	hand.set_all_draggable(false)


func on_text_finish() -> void:
	hand.set_all_draggable(true)


func _on_end_round_button_pressed() -> void:
	end_round_button.disabled = true
	view_deck_button.disabled = true
	view_discard_button.disabled = true

	hand.set_all_draggable(false)

	# Make enemy moves
	var looping_index := curr_round % (Global.card_replay_moves.size() + COPY_ROUND_DOWNTIME)
	if Global.card_replay_moves.has(looping_index):
		for move in Global.card_replay_moves[looping_index]:
			if move[0].card_role == "Attack":
				enemy_attack_card.initialize(move[0])
				enemy_attack_card.show()
			else:
				enemy_defense_card.initialize(move[0])
				enemy_defense_card.show()

			await perform_card(move[0], move[1], true)
			await wait_for_timer(Global.animation_speed * 2)
			enemy_attack_card.hide()
			enemy_defense_card.hide()

	await instant_defensive_damage()
	await offensive_action_sweep()

	await wait_for_timer(Global.animation_speed)

	if hand.cards.size() < MAX_CARDS_IN_HAND:
		await draw_cards(1)
	curr_round += 1

	end_round_button.disabled = false
	view_deck_button.disabled = false
	view_discard_button.disabled = false
	hand.set_all_draggable(true)
	turn_finished.emit()


func _on_card_dropped(card: Control) -> void:
	var grid_pos := Vector2i(-1, -1)
	var points := drop_points.get_children()
	points.append($InfoDropPoint/LaneInfo)
	for drop in points:
		if drop.is_mouse_inside:
			grid_pos = drop.grid_position
			break
	if grid_pos.y < 0 or grid_pos.x < 0 or grid_pos.x > 10 or grid_pos.y > 6:
		return
	if grid_pos.y == 6:		# Help box
		var attack_card := card.card_data.attack as CardData
		var defense_card := card.card_data.defense as CardData
		card_info_viewer.update(attack_card, defense_card)
		card_info_viewer.show()
		return
	if grid_pos.y < 3 and get_unit(grid_pos):
		return # Don't want to waste an attacking unit by overriding it before it can go
	if grid_pos.y in [3, 4, 5] and get_unit(grid_pos):
		var existing_unit := get_unit(grid_pos)
		var new_card := card.card_data.defense as CardData
		if new_card is RangedUnitData:
			if existing_unit.attack_damage >= new_card.attack_damage:
				return	# Don't overwrite with a defensive unit of a lower or equal rank
	# We have a thing to put down! Let's do it
	var data: CardData
	if grid_pos.y < 3:
		data = card.card_data.attack
	else:
		data = card.card_data.defense
	var should_remove := can_perform_card(data, grid_pos)
	if should_remove:
		discard.append(card.card_data)
		hand.remove_card(card)
	end_round_button.disabled = true
	await perform_card(data, grid_pos)
	end_round_button.disabled = false


func remove_info(card_container: Node) -> void:
	card_info_viewer.hide()
	card_container.queue_free()


func draw_cards(num_cards: int) -> void:
	hand.set_all_draggable(false)
	for _idx in range(num_cards):
		await draw_card_single()

	hand.set_all_draggable(true)


func draw_card_single() -> void:
	# If the deck is empty, rearrange the cards from discard.
	if deck.size() == 0:
		deck = discard.duplicate()
		deck.shuffle()
		discard.clear()
		if deck.size() == 0:
			return

	var dual_card_data = deck.pop_front()
	hand.add_card(dual_card_data)

	draw_sound.play()

	await wait_for_timer(Global.animation_speed)


func card_script_setup(data: CardData, grid_pos: Vector2i, is_enemy := false) -> Array:
	if data.effect_script == null:
		push_error("CardData %s has no script!", data.name)
		return [false]
	var card_script := load(data.effect_script)
	if card_script == null or not (card_script is Script):
		push_error("CardData %s has invalid script!", data.name)
		return [false]
	var script_node_generic = Node.new() # Is this the right way to do it?
	add_child(script_node_generic)
	script_node_generic.set_script(card_script)
	var script_node: CardAction = script_node_generic
	script_node.set_game(self)
	if is_enemy:
		if grid_pos.y < 3:
			grid_pos.y += 3
		else:
			grid_pos.y -= 3
	return [true, script_node, grid_pos]


func can_perform_card(data: CardData, grid_pos: Vector2i, is_enemy := false) -> bool:
	var setup := card_script_setup(data, grid_pos, is_enemy)
	if not setup[0]:
		return false
	var script_node: CardAction = setup[1]
	grid_pos = setup[2]
	var success := script_node.can_perform(data, grid_pos, is_enemy)
	remove_child(script_node)
	script_node.queue_free()
	return success


func perform_card(data: CardData, grid_pos: Vector2i, is_enemy := false) -> bool:
	var setup := card_script_setup(data, grid_pos, is_enemy)
	if not setup[0]:
		return false
	var script_node: CardAction = setup[1]
	grid_pos = setup[2]
	var success := script_node.can_perform(data, grid_pos, is_enemy)
	if success:
		@warning_ignore("redundant_await") # Not all need the await call
		await script_node.perform_action(data, grid_pos, is_enemy)
		if not is_enemy:
			if not Global.card_current_moves.has(curr_round):
				Global.card_current_moves[curr_round] = []
			Global.card_current_moves[curr_round].append([data, grid_pos])
	remove_child(script_node)
	script_node.queue_free()
	return success


func instant_defensive_damage() -> void:
	var units := $Units/Ranged.get_children()
	units.sort_custom(ranged_attack_order)
	for unit in units:
		# Search for the closest non-empty square within the range.
		var target: Node = null
		for x_pos in range(7, 7 - unit.attack_range, -1):
			target = get_unit(Vector2i(x_pos, unit.grid_position.y))
			if target != null:
				break

		if target == null:
			continue

		# Move the archer forward, slightly.
		var position_offset := Vector2(10.0, 0.0)
		if unit.grid_position.y < 3:
			position_offset *= -1.0
		unit.position += position_offset
		unit.play_shoot_sound()
		await wait_for_timer(Global.animation_speed)
		# Do the attack.
		target.health -= unit.attack_damage
		target.update_health_bar()
		target.play_damage_sound()
		await wait_for_timer(Global.animation_speed)
		# Kill the target, if necessary.
		if target.health <= 0:
			target.queue_free()
			$Units/Melee.remove_child(target)
			await wait_for_timer(Global.animation_speed)
		# Move the archer back.
		unit.update_position()
		await wait_for_timer(Global.animation_speed)


func offensive_action_sweep() -> void:
	var units := $Units/Melee.get_children()
	units.sort_custom(melee_attack_order)
	for unit in units:
		if game_over:
			break
		if unit == null or unit.is_queued_for_deletion():
			continue
		var steps_left = unit.speed
		for _idx in range(unit.speed):
			if is_spot_open(unit.grid_position + Vector2i.RIGHT):
				unit.play_step_sound()
				unit.grid_position += Vector2i.RIGHT
				unit.update_position()
				steps_left -= 1
				await wait_for_timer(Global.animation_speed)
		if unit.attack_power > 0 and unit.grid_position.x == 7 and steps_left:
			await melee_attack(unit)
	# for each offensive square, check if a unit is occupying that square
	# if so, call that unit's offensive_action function


func melee_attack(unit: Unit) -> void:
	var damage = unit.attack_power
	# Handle battering rams (ugly, but it should work).
	if unit.grid_position.y in [1, 2]:
		var neighbor = get_unit(unit.grid_position + Vector2i.UP)
		if neighbor != null and neighbor.attack_power == 0:
			damage += 2
	if unit.grid_position.y in [0, 1]:
		var neighbor = get_unit(unit.grid_position + Vector2i.DOWN)
		if neighbor != null and neighbor.attack_power == 0:
			damage += 2
	if unit.grid_position.y in [3, 4]:
		var neighbor = get_unit(unit.grid_position + Vector2i.DOWN)
		if neighbor != null and neighbor.attack_power == 0:
			damage += 2
	if unit.grid_position.y in [4, 5]:
		var neighbor = get_unit(unit.grid_position + Vector2i.UP)
		if neighbor != null and neighbor.attack_power == 0:
			damage += 2

	unit.play_step_sound()
	if unit.grid_position.y > 2:
		unit.position = blue_castle_door
		await wait_for_timer(Global.animation_speed)
		blue_castle_health_bar.modify_health(-damage)
	else:
		unit.position = red_castle_door
		await wait_for_timer(Global.animation_speed)
		red_castle_health_bar.modify_health(-damage)
	check_for_end_condition()
	if game_over:
		return
	unit.health -= unit.recoil
	unit.update_health_bar()
	unit.play_damage_sound()
	await wait_for_timer(Global.animation_speed)
	if unit.health <= 0:
		$Units/Melee.remove_child(unit)
		unit.queue_free()
	else:
		unit.update_position()
		await wait_for_timer(Global.animation_speed)


func melee_attack_order(a, b) -> bool:
	if b.grid_position.y > a.grid_position.y:
		return true
	elif b.grid_position.y < a.grid_position.y:
		return false
	else:
		if b.grid_position.x < a.grid_position.x:
			return true
		else:
			return false


func ranged_attack_order(a, b) -> bool:
	if b.grid_position.y > a.grid_position.y:
		return false
	else:
		return true


func check_for_end_condition() -> void:
	if red_castle_health_bar.current_health <= 0:
		win_sound.play()
		if Global.curr_stage >= 5 and not Global.endless_mode:
			get_tree().change_scene_to_file("res://src/states/menu/win_screen.tscn")
		game_over = true
		end_round_button.hide()
		view_deck_button.hide()
		view_discard_button.hide()
		if Global.curr_stage == 1 and not Global.endless_mode:
			text_box.play(preload("res://assets/dialog/dialog_6.tres"))
			await text_box.text_finished
		var card_draft_ranks_idx := mini(Global.curr_stage, Global.draft_card_ranks_per_stage.size() - 1)
		card_drafting.select_card_set(Global.draft_card_ranks_per_stage[card_draft_ranks_idx][0],
				Global.draft_card_ranks_per_stage[card_draft_ranks_idx][1])
		card_drafting.show()
	elif blue_castle_health_bar.current_health <= 0:
		game_over = true
		get_tree().change_scene_to_file("res://src/states/menu/lose_screen.tscn")	# Game over screen


func _on_view_deck_button_pressed() -> void:
	card_viewer.update_cards(deck)
	card_viewer.show()
	pause(card_viewer)


func _on_view_discard_button_pressed() -> void:
	card_viewer.update_cards(discard)
	card_viewer.show()
	pause(card_viewer)


func close_card_viewer() -> void:
	card_viewer.hide()
	resume()
