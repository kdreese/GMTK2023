extends Node2D


signal turn_finished


const RED_CASTLE_DOOR = Vector2(160, 240)
const BLUE_CASTLE_DOOR = Vector2(480, 80)
const MAX_CARDS_IN_HAND = 5
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
@onready var red_castle_health_bar: CastleHealthBar = $RedCastleHealthBar
@onready var blue_castle_health_bar: CastleHealthBar = $BlueCastleHealthBar
@onready var card_nodes: CanvasLayer = $CardCanvasLayer
@onready var end_round_button: Button = %EndRoundButton
@onready var view_deck_button: Button = %ViewDeckButton
@onready var view_discard_button: Button = %ViewDiscardButton
@onready var text_box: TextBox = %TextBox
@onready var info_display: CenterContainer = %InfoDisplay
@onready var enemy_attack_card: Control = $EnemyAttackCard
@onready var enemy_defense_card: Control = $EnemyDefenseCard
@onready var card_viewer: Control = %CardViewer

@onready var lane_drops: Array[Area2D] = [
	$AttackDropPoints/Lane0, $AttackDropPoints/Lane1, $AttackDropPoints/Lane2,
	$DefenseDropPoints/Lane3, $DefenseDropPoints/Lane4, $DefenseDropPoints/Lane5,
	$InfoDropPoint/LaneInfo,
]


var enemy_moves: Array[Dictionary]
var deck: Array[DualCardData]
var hand: Array[DualCardData]
var discard: Array[DualCardData]
var curr_round: int = 0
var red_max_health: int = 30
var blue_max_health: int = 50

var put_down_this_turn := [false, false, false] # In the attacking lanes, have we put something down this turn yet?

var game_over := false


func _ready() -> void:
	text_box.lines.clear()
	options_menu.get_node("%BackButton").pressed.connect(hide_options)
	text_box.text_finished.connect(on_text_finish)
	text_box.text_started.connect(on_text_start)
	card_viewer.close_requested.connect(close_card_viewer)
	red_castle_health_bar.initialize(ROUND_HEALTHS[Global.curr_stage][0], true)
	blue_castle_health_bar.initialize(ROUND_HEALTHS[Global.curr_stage][1], false)
	info_display.hide()
	curr_round = 0

	deck = Global.deck.duplicate()

	if Global.curr_stage == 0:
		Global.card_replay_moves = Global.FIRST_REPLAY_MOVES

	if not Global.endless_mode and Global.curr_stage == 0:
		end_round_button.disabled = true
		draw_card()
		text_box.play(preload("res://assets/dialog/dialog_1.tres"))
		await text_box.text_finished
		%OffenseMask.show()
		while card_nodes.get_child_count() > 0:
			await card_nodes.get_children()[0].dropped_card
		%OffenseMask.hide()
		text_box.play(preload("res://assets/dialog/dialog_2.tres"))
		await text_box.text_finished
		end_round_button.disabled = false
		await turn_finished
		end_round_button.disabled = true
		text_box.play(preload("res://assets/dialog/dialog_3.tres"))
		await text_box.text_finished
		%DefenseMask.show()
		while card_nodes.get_child_count() > 0:
			await card_nodes.get_children()[0].dropped_card
		%DefenseMask.hide()
		text_box.play(preload("res://assets/dialog/dialog_3_5.tres"))
		await text_box.text_finished
		end_round_button.disabled = false
		await turn_finished
		text_box.play(preload("res://assets/dialog/dialog_4.tres"))
		await text_box.text_finished
		await turn_finished
		end_round_button.disabled = true
		await draw_card()
		await draw_card()
		text_box.play(preload("res://assets/dialog/dialog_5.tres"))
		await text_box.text_finished
		end_round_button.disabled = false
	else:
		deck.shuffle()
		for i in range(3):
			await draw_card()

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
	for card in card_nodes.get_children():
		card.draggable = false


func on_text_finish() -> void:
	for card in card_nodes.get_children():
		card.draggable = true


func _on_end_round_button_pressed() -> void:
	end_round_button.disabled = true
	view_deck_button.disabled = true
	view_discard_button.disabled = true

	for card in card_nodes.get_children():
		card.draggable = false

	# Make enemy moves
	var looping_index := curr_round % (Global.card_replay_moves.size() + COPY_ROUND_DOWNTIME)
	if Global.card_replay_moves.has(looping_index):
		for move in Global.card_replay_moves[looping_index]:
			if move[0].card_role == "Attack":
				enemy_attack_card.initialize(move[0])
				enemy_attack_card.show()
				await wait_for_timer(Global.animation_speed * 2)
				enemy_attack_card.hide()
			else:
				enemy_defense_card.initialize(move[0])
				enemy_defense_card.show()
				await wait_for_timer(Global.animation_speed * 2)
				enemy_defense_card.hide()
			perform_card(move[0], move[1], true)

	await instant_defensive_damage()
	await offensive_action_sweep()
	if hand.size() < MAX_CARDS_IN_HAND:
		await draw_card()
	curr_round += 1

	end_round_button.disabled = false
	view_deck_button.disabled = false
	view_discard_button.disabled = false
	put_down_this_turn = [false, false, false]
	for card in card_nodes.get_children():
		card.draggable = true
	turn_finished.emit()


func _on_card_dropped(card: Control) -> void:
	var lane := -1
	for drop in lane_drops:
		if drop.is_mouse_inside:
			lane = drop.lane_index
			break
	if lane < 0:
		return
	if lane > 5:		# Help box
		var info_container := VBoxContainer.new()
		var card_container := HBoxContainer.new()
		var attack_card := card.card_data.attack as CardData
		var attack_card_node := preload("res://src/cards/attack/attack_card_info.tscn").instantiate()
		var defense_card := card.card_data.defense as CardData
		var defense_card_node := preload("res://src/cards/defense/defense_card_info.tscn").instantiate()
		var close_button := Button.new()
		close_button.pressed.connect(self.remove_info.bind(info_container))
		close_button.text = "Close"
		card_container.add_child(attack_card_node)
		card_container.add_child(defense_card_node)
		info_container.add_child(card_container)
		info_container.add_child(close_button)
		info_display.add_child(info_container)
		attack_card_node.initialize(attack_card)
		defense_card_node.initialize(defense_card)
		info_display.show()
		return
	if lane < 3 and put_down_this_turn[lane]:
		return # Don't want to waste an attacking unit by overriding it before it can go
	if lane in [3, 4, 5] and get_unit(Vector2i(0, lane)):
		var existing_unit := get_unit(Vector2i(0, lane))
		var new_card := card.card_data.defense as CardData
		if new_card is RangedUnitData:
			if existing_unit.attack_damage >= new_card.attack_damage:
				return	# Don't overwrite with a defensive unit of a lower or equal rank
	# We have a thing to put down! Let's do it
	var data: CardData
	if lane < 3:
		data = card.card_data.attack
		put_down_this_turn[lane] = true
	else:
		data = card.card_data.defense
	var should_remove := perform_card(data, lane)
	if should_remove:
		card_nodes.remove_child(card)
		arrange_cards()
		card.queue_free()
		discard.append(card.card_data)
		hand.remove_at(hand.find(card.card_data))


func remove_info(card_container: Node) -> void:
	info_display.hide()
	card_container.queue_free()


func draw_card() -> void:
	# If the deck is empty, rearrange the cards from discard.
	if deck.size() == 0:
		deck = discard.duplicate()
		deck.shuffle()
		discard.clear()
		if deck.size() == 0:
			return

	var dual_card_data = deck.pop_front()
	hand.append(dual_card_data)
	var card = preload("res://src/cards/dual_card.tscn").instantiate()
	card_nodes.add_child(card)
	card.initialize(dual_card_data)
	card.dropped_card.connect(self._on_card_dropped)
	arrange_cards()

	await wait_for_timer(Global.animation_speed * 2)


func perform_card(data: CardData, lane: int, is_enemy := false) -> bool:
	if data.effect_script == null:
		push_error("CardData %s has no script!", data.name)
		return false
	var card_script := load(data.effect_script)
	if card_script == null or not (card_script is Script):
		push_error("CardData %s has invalid script!", data.name)
		return false
	var script_node_generic = Node.new() # Is this the right way to do it?
	add_child(script_node_generic)
	script_node_generic.set_script(card_script)
	var script_node: CardAction = script_node_generic
	script_node.set_game(self)
	if is_enemy:
		if lane < 3:
			lane += 3
		else:
			lane -= 3
	var success := script_node.can_perform(data, lane)
	if success:
		script_node.perform_action(data, lane)
		if not is_enemy:
			if not Global.card_current_moves.has(curr_round):
				Global.card_current_moves[curr_round] = []
			Global.card_current_moves[curr_round].append([data, lane])
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
		await wait_for_timer(Global.animation_speed)
		# Do the attack.
		target.health -= unit.attack_damage
		target.update_health_bar()
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
		if unit == null:
			continue
		if unit.is_queued_for_deletion():
			continue
		var steps_left = unit.speed
		for _idx in range(unit.speed):
			if is_spot_open(unit.grid_position + Vector2i.RIGHT):
				unit.grid_position += Vector2i.RIGHT
				unit.update_position()
				steps_left -= 1
				await wait_for_timer(Global.animation_speed)
		if unit.grid_position.x == 7 and steps_left:
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

	if unit.grid_position.y > 2:
		unit.position = RED_CASTLE_DOOR
		await wait_for_timer(Global.animation_speed)
		red_castle_health_bar.current_health -= damage
		red_castle_health_bar.update()
	else:
		unit.position = BLUE_CASTLE_DOOR
		await wait_for_timer(Global.animation_speed)
		blue_castle_health_bar.current_health -= damage
		blue_castle_health_bar.update()
	check_for_end_condition()
	if game_over:
		return
	unit.health -= unit.recoil
	unit.update_health_bar()
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
	if blue_castle_health_bar.current_health <= 0:
		if Global.curr_stage >= 5:
			get_tree().change_scene_to_file("res://src/states/menu/win_screen.tscn")
		game_over = true
		end_round_button.hide()
		view_deck_button.hide()
		view_discard_button.hide()
		if Global.curr_stage == 1 and not Global.endless_mode:
			text_box.play(preload("res://assets/dialog/dialog_6.tres"))
			await text_box.text_finished
		card_drafting.select_card_set(Global.draft_card_ranks_per_stage[Global.curr_stage][0],\
				Global.draft_card_ranks_per_stage[Global.curr_stage][1])
		card_drafting.show()
	elif red_castle_health_bar.current_health <= 0:
		game_over = true
		get_tree().change_scene_to_file("res://src/states/menu/lose_screen.tscn")	# Game over screen


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
