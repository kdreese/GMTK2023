class_name DualCard
extends Control


signal started_drag(card: DualCard)
signal dropped_card(card: DualCard)

const MOUSEOVER_OFFSET := Vector2(0, -50)
const MAX_FONT_SIZE = 11

var card_data: DualCardData

var draggable := true ## If the card can be dragged
var dragging := false ## Whether or not this card is being dragged
var hand_position: Vector2 ## The screen position of the card when in the hand
var original_size: Vector2 ## The original size of the top-level control node.
var drop_lane := -1 ## In which lane the card will be dropped, 0-5. -1 means not used

@onready var rank_icon: TextureRect = $RankIcon
@onready var attack_label: Label = $AttackLabel
@onready var attack_icon: TextureRect = $AttackIcon
@onready var defense_icon: TextureRect = $DefenseIcon
@onready var defense_label: Label = $DefenseLabel
@onready var hover_sound: AudioStreamPlayer = $HoverSound


# For debugging only
func _ready() -> void:
	original_size = size
	hand_position = position


func _process(_delta: float) -> void:
	if dragging:
		if not draggable:
			dragging = false
			position = hand_position
			rotation = 0.0
			scale = Vector2.ONE
		else:
			position = get_viewport().get_mouse_position()


func initialize(data: DualCardData) -> void:
	card_data = data
	rank_icon.texture = Util.rank_to_texture(data.rank)
	hide_all()
	if data.attack != null:
		attack_label.text = data.attack.name
		Util.fit_text(attack_label, MAX_FONT_SIZE)
		attack_icon.texture = data.attack.icon
		attack_icon.show()
		update_icons(data.attack, $AttackStats)
	if data.defense != null:
		defense_label.text = data.defense.name
		Util.fit_text(defense_label, MAX_FONT_SIZE)
		defense_icon.texture = data.defense.icon
		defense_icon.show()
		update_icons(data.defense, $DefenseStats)


func hide_all() -> void:
	for node in $AttackStats.get_children():
		node.hide()
	attack_label.text = ""
	attack_icon.hide()
	for node in $DefenseStats.get_children():
		node.hide()
	defense_label.text = ""
	defense_icon.hide()


func update_icons(data: CardData, grid: GridContainer) -> void:
	for node in grid.get_children():
		node.hide()
	if data.info_show_flags & CardData.SHOW_HEALTH_FLAG:
		grid.get_node("HealthIcon").show()
		grid.get_node("HealthLabel").show()
		var text := data.stat_string_overrides["health"] as String
		if text == "":
			text = str(data.health)
		grid.get_node("HealthLabel").text = text
	if data.info_show_flags & CardData.SHOW_MOVEMENT_FLAG:
		grid.get_node("MvmtIcon").show()
		grid.get_node("MvmtLabel").show()
		var text := data.stat_string_overrides["movement"] as String
		if text == "":
			text = str(data.movement)
		grid.get_node("MvmtLabel").text = text
	if data.info_show_flags & CardData.SHOW_DAMAGE_FLAG:
		grid.get_node("AttIcon").show()
		grid.get_node("AttLabel").show()
		var text := data.stat_string_overrides["damage"] as String
		if text == "":
			text = str(data.damage)
		grid.get_node("AttLabel").text = text
	if data.info_show_flags & CardData.SHOW_RANGE_FLAG:
		grid.get_node("RangeIcon").show()
		grid.get_node("RangeLabel").show()
		var text := data.stat_string_overrides["att_range"] as String
		if text == "":
			text = str(data.att_range)
		grid.get_node("RangeLabel").text = text
	if data.special:
		grid.get_node("SpecialLabel").show()
		grid.get_node("SpecialIcon").show()


func raise_instant() -> void:
	self.position = self.hand_position + MOUSEOVER_OFFSET
	self.size = self.original_size - MOUSEOVER_OFFSET


func _on_mouse_enter() -> void:
	if draggable and not dragging:
		hover_sound.play()
		get_tree().create_tween().tween_property(self, "position", self.hand_position + MOUSEOVER_OFFSET, 0.1)
		get_tree().create_tween().tween_property(self, "size", self.original_size - MOUSEOVER_OFFSET, 0.1)


func _on_mouse_exit() -> void:
	if draggable and not dragging:
		get_tree().create_tween().tween_property(self, "position", self.hand_position, 0.1)
		get_tree().create_tween().tween_property(self, "size", self.original_size, 0.1)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton
		if draggable and mb_event.button_index == 1:
			if mb_event.pressed and not dragging:
				dragging = true
				rotation = -0.5 # radians
				scale = Vector2(0.5, 0.5)
				started_drag.emit(self)
			elif not mb_event.pressed and dragging:
				dragging = false
				position = hand_position
				rotation = 0.0
				scale = Vector2.ONE
				dropped_card.emit(self)
