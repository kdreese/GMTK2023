class_name GameScene
extends Node2D


signal turn_finished


enum SoundEffect {
	DRAW,
	PLACE,
	HEAL,
	OIL,
	WIN,
	CHARGE,
}


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
@onready var enemy_card: Control = $EnemyCard
@onready var card_viewer: Control = %CardViewer
@onready var hand: Hand = %Hand
@onready var attack_script_node: Node = %AttackScriptNode
@onready var defense_script_node: Node = %DefenseScriptNode
@onready var enemy_script_node: Node = %EnemyScriptNode

@onready var drop_points: Node2D = %DropPoints
@onready var blue_castle_door: Vector2 = $DefenseBridgePoint.position
@onready var red_castle_door: Vector2 = $AttackBridgePoint.position


var grid_to_world_pos: Dictionary # Dictionary[Vector2i, Vector2]
var enemy_moves: Array[Dictionary]
var deck: Array[DualCardData]
var discard: Array[DualCardData]
var curr_round: int = 0
var red_max_health: int = 30
var blue_max_health: int = 50
var can_display_tooltip := true

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


func play_sound(sound: SoundEffect, is_left: bool = true) -> void:
	match sound:
		SoundEffect.DRAW:
			$Sounds/DrawSound.play()
		SoundEffect.PLACE:
			if is_left:
				$Sounds/LeftPlaceSound.play()
			else:
				$Sounds/RightPlaceSound.play()
		SoundEffect.HEAL:
			if is_left:
				$Sounds/LeftHealSound.play()
			else:
				$Sounds/RightHealSound.play()
		SoundEffect.OIL:
			if is_left:
				$Sounds/LeftOilSound.play()
			else:
				$Sounds/RightOilSound.play()
		SoundEffect.WIN:
			$Sounds/WinSound.play()
		SoundEffect.CHARGE:
			if is_left:
				$Sounds/LeftCharge.play()
			else:
				$Sounds/RightCharge.play()
		_:
			# $Sounds/ExtremelyLoudIncorrectBuzzer.play()
			push_error("Invalid sound effect.")


func is_spot_open(grid_position: Vector2i):
	if grid_position.x > 7:
		return false
	for unit in $Units/Melee.get_children() + $Units/Barricade.get_children():
		if unit.grid_position == grid_position:
			return false
	return true


func get_unit(grid_position: Vector2i) -> Unit:
	for unit in $Units/Melee.get_children() + $Units/Ranged.get_children() + $Units/Barricade.get_children():
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

	can_display_tooltip = false
	for point in drop_points.get_children():
		if point.open_tooltip != null:
			point.close_tooltip()

	# Make enemy moves
	var looping_index := curr_round % (Global.card_replay_moves.size() + COPY_ROUND_DOWNTIME)
	if Global.card_replay_moves.has(looping_index):
		for move in Global.card_replay_moves[looping_index]:
			enemy_card.initialize(move[0])
			enemy_card.show()
			load_enemy_script(move[0])
			await enemy_script_node.perform_action(move[1], true)
			await wait_for_timer(Global.animation_speed * 2)
			enemy_card.hide()

	await instant_defensive_damage()
	await offensive_action_sweep()

	await wait_for_timer(Global.animation_speed)

	if hand.cards.size() < MAX_CARDS_IN_HAND and not game_over:
		await draw_cards(1)
	curr_round += 1

	clear_unit_effects()

	end_round_button.disabled = false
	view_deck_button.disabled = false
	view_discard_button.disabled = false
	hand.set_all_draggable(true)
	can_display_tooltip = true
	for point in drop_points.get_children():
		point.check_for_start_tooltip()
	turn_finished.emit()


func on_card_dragged(card: DualCard) -> void:
	can_display_tooltip = false
	load_scripts(card.card_data)
	for drop_point in drop_points.get_children():
		var script_node: Node
		if drop_point.grid_position.y < 3:
			script_node = attack_script_node
		else:
			script_node = defense_script_node
		if script_node.can_perform(drop_point.grid_position, false):
			drop_point.set_enabled(true)
		else:
			drop_point.set_enabled(false)


func clear_effects() -> void:
	for drop_point in drop_points.get_children():
		drop_point.reset()


func clear_unit_effects() -> void:
	for unit in $Units/Melee.get_children() + $Units/Ranged.get_children() as Array[Unit]:
		unit.extra_stats = {}


func on_card_enter(drop_point: Node) -> void:
	if not drop_point.enabled or drop_point.grid_position.y == 6:
		return
	if not hand.cards.any(func dragging(x): return x.dragging):
		return
	clear_effects()
	var script_node: Node
	if drop_point.grid_position.y < 3:
		script_node = attack_script_node
	else:
		script_node = defense_script_node
	var negative_tiles := script_node.negative_effects(drop_point.grid_position) as Array[Vector2i]
	var positive_tiles := script_node.positive_effects(drop_point.grid_position) as Array[Vector2i]
	for other_drop_point in drop_points.get_children():
		if other_drop_point.grid_position in negative_tiles:
			other_drop_point.set_negative()
		elif other_drop_point.grid_position in positive_tiles:
			other_drop_point.set_positive()


func on_card_exit() -> void:
	if not drop_points.get_children().any(func is_inside(x): return x.is_mouse_inside):
		clear_effects()


func _on_card_dropped(card: DualCard) -> void:
	var points := drop_points.get_children()
	for drop in points:
		drop.set_enabled(true)
	can_display_tooltip = true
	# Help box.
	if $InfoDropPoint/LaneInfo.is_mouse_inside:
		var attack_card := card.card_data.attack as CardData
		var defense_card := card.card_data.defense as CardData
		card_info_viewer.update(attack_card, defense_card)
		card_info_viewer.show()
		return
	var grid_pos := Vector2i(-1, -1)
	for drop in points:
		if drop.is_mouse_inside:
			grid_pos = drop.grid_position
	if grid_pos.y < 0 or grid_pos.x < 0 or grid_pos.x > 10 or grid_pos.y > 6:
		return

	# We have a thing to put down! Let's do it
	var script_node: Node
	if grid_pos.y < 3:
		script_node = attack_script_node
	else:
		script_node = defense_script_node
	if script_node.can_perform(grid_pos, false):
		if not card.card_data.single_use:
			discard.append(card.card_data)
		hand.remove_card(card)
		end_round_button.disabled = true
		@warning_ignore("redundant_await") # Not all need the await call
		await script_node.perform_action(grid_pos, false)
		if not Global.card_current_moves.has(curr_round):
			Global.card_current_moves[curr_round] = []
			# Flip the lanes around here so that enemy cards get put in the right spot.
			var modified_grid_pos: = grid_pos
			if modified_grid_pos.y < 3:
				modified_grid_pos.y += 3
			else:
				modified_grid_pos.y -= 3
			Global.card_current_moves[curr_round].append([script_node.data, modified_grid_pos])
		var this_unit := get_unit(grid_pos)
		if this_unit != null and this_unit.card_data.name == "Battering Ram":
			apply_battering_ram_buff(this_unit)
	end_round_button.disabled = false


func apply_battering_ram_buff(unit: Unit) -> void:
	for drop_point in drop_points.get_children():
		if drop_point.grid_position == unit.grid_position + Vector2i.UP or drop_point.grid_position == unit.grid_position + Vector2i.DOWN:
			if drop_point.extra_stats.has("attack_power"):
				drop_point.extra_stats["attack_power"] += int(unit.card_data.extra_data[0])
			else:
				drop_point.extra_stats["attack_power"] = int(unit.card_data.extra_data[0])


func remove_battering_ram_buff(unit: Unit) -> void:
	for drop_point in drop_points.get_children():
		if drop_point.grid_position == unit.grid_position + Vector2i.UP or drop_point.grid_position == unit.grid_position + Vector2i.DOWN:
			if drop_point.extra_stats.has("attack_power"):
				drop_point.extra_stats["attack_power"] -= int(unit.card_data.extra_data[0])
			else:
				drop_point.extra_stats["attack_power"] = 0


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

	play_sound(SoundEffect.DRAW)

	await wait_for_timer(Global.animation_speed)


## Load a script from a CardData and set it to be the script for the given node.
func load_script(data: CardData, node: Node) -> bool:
	var card_script: Script
	if data == null:
		card_script = load("res://src/cards/actions/blank.gd")
	else:
		if data.effect_script == null:
			assert(false, "CardData %s has no script!" % data.name)
			return false
		card_script = load(data.effect_script)
	if card_script == null or not (card_script is Script):
		assert(false, "CardData %s has invalid script!" % data.name)
		return false
	node.set_script(card_script)
	node.initialize(self, data)
	return true


## Loads both scripts for a dual card.
func load_scripts(data: DualCardData) -> bool:
	if not load_script(data.attack, attack_script_node):
		return false
	if not load_script(data.defense, defense_script_node):
		return false
	return true


## Loads the script for the enemy action.
func load_enemy_script(data: CardData) -> bool:
	return load_script(data, enemy_script_node)


func instant_defensive_damage() -> void:
	var units := $Units/Ranged.get_children()
	units.sort_custom(ranged_attack_order)
	for unit in units:
		if unit.attack_range == 0 or unit.attack_damage == 0:
			continue
		var attack_range := unit.attack_range as int
		attack_range += unit.extra_stats.get("attack_range", 0)
		# Search for the closest non-empty square within the range.
		var target: Node = null
		for x_pos in range(7, 7 - attack_range, -1):
			target = get_unit(Vector2i(x_pos, unit.grid_position.y))
			if target != null:
				break

		if target == null:
			continue

		if target is BarricadeUnit:
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
			target.commit_die()
			await wait_for_timer(Global.animation_speed)
		# Move the archer back.
		unit.update_position()
		await wait_for_timer(Global.animation_speed)


func offensive_action_sweep() -> void:
	var units := $Units/Melee.get_children()
	units.sort_custom(melee_attack_order)
	for unit in units as Array[MeleeUnit]:
		if game_over:
			break
		if unit == null or unit.is_queued_for_deletion():
			continue
		var steps_left = unit.speed + unit.extra_stats.get("speed", 0)
		if steps_left != 0 and unit.card_data.name == "Battering Ram":
			remove_battering_ram_buff(unit)
		for _idx in range(steps_left):
			if is_spot_open(unit.grid_position + Vector2i.RIGHT):
				unit.play_step_sound()
				unit.grid_position += Vector2i.RIGHT
				unit.update_position()
				steps_left -= 1
				await wait_for_timer(Global.animation_speed)
			elif unit.grid_position.x < 7: # We're not at the end, we got blocked
				var blocking_unit := get_unit(unit.grid_position + Vector2i.RIGHT)
				assert(blocking_unit, "Blocking unit is null?")
				if blocking_unit is BarricadeUnit:
					# This is an enemy unit! Attack!!
					await melee_attack(unit, blocking_unit)
				break
		if unit.card_data.name == "Battering Ram":
			apply_battering_ram_buff(unit)
		if unit.attack_power > 0 and unit.grid_position.x == 7 and steps_left:
			await melee_attack(unit)


func melee_attack(unit: Unit, attack_target: BarricadeUnit = null) -> void:
	var damage = unit.attack_power + unit.extra_stats.get("attack_power", 0)

	# apply battering ram on attack
	for drop_point in drop_points.get_children():
		if unit.grid_position == drop_point.grid_position and drop_point.extra_stats.has("attack_power"):
			damage += drop_point.extra_stats.get("attack_power", 0)

	unit.play_step_sound()
	if attack_target == null:
		# We're attacking the castle
		unit.play_damage_sound()
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
	else:
		attack_target.play_hit_barricade_sound()
		if unit.grid_position.y > 2:
			unit.position += Vector2.LEFT * 10
		else:
			unit.position += Vector2.RIGHT * 10
		await wait_for_timer(Global.animation_speed)
		attack_target.health -= damage
		attack_target.update_health_bar()
	await wait_for_timer(Global.animation_speed)
	if unit.health <= 0:
		unit.commit_die()
	else:
		unit.update_position()
	if attack_target:
		if attack_target.health <= 0:
			attack_target.commit_die()
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
		play_sound(SoundEffect.WIN)
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
		card_drafting.set_ranks(Global.draft_card_ranks_per_stage[card_draft_ranks_idx])
		card_drafting.select_card_set()
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
