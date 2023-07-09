extends Control


signal dropped_card(Control)

const DRAGGING_OFFSET := Vector2(-32, -18)

var card_data: DualCardData

var draggable := true ## If the card can be dragged
var dragging := false ## Whether or not this card is being dragged
var hand_position: Vector2 ## The screen position of the card when in the hand
var drop_lane := -1 ## In which lane the card will be dropped, 0-5. -1 means not used


@onready var rank_icon: TextureRect = $RankIcon
@onready var attack_label: Label = $AttackLabel
@onready var attack_icon: TextureRect = $AttackIcon
@onready var defense_icon: TextureRect = $DefenseIcon
@onready var defense_label: Label = $DefenseLabel


# For debugging only
func _ready() -> void:
	hand_position = position


func _process(_delta: float) -> void:
	if dragging:
		if not draggable:
			dragging = false
			position = hand_position
			rotation = 0.0
			scale = Vector2.ONE
		else:
			position = get_viewport().get_mouse_position() + DRAGGING_OFFSET


func initialize(data: DualCardData) -> void:
	card_data = data
	rank_icon.texture = Util.rank_to_texture(data.rank)
	attack_label.text = data.attack.short_name
	attack_icon.texture = data.attack.icon
	defense_label.text = data.defense.short_name
	defense_icon.texture = data.defense.icon
	update_icons(data.attack, $AttackStats)
	update_icons(data.defense, $DefenseStats)


func update_icons(data: CardData, grid: GridContainer) -> void:
	for node in grid.get_children():
		node.hide()
	if data is MeleeUnitData:
		grid.get_node("HealthLabel").show()
		grid.get_node("HealthLabel").text = str(data.health)
		grid.get_node("HealthIcon").show()
		grid.get_node("AttLabel").show()
		grid.get_node("AttLabel").text = str(data.attack_power)
		grid.get_node("AttIcon").show()
		grid.get_node("MvmtLabel").show()
		grid.get_node("MvmtLabel").text = str(data.speed)
		grid.get_node("MvmtIcon").show()
	elif data is RangedUnitData:
		grid.get_node("AttLabel").show()
		grid.get_node("AttLabel").text = str(data.attack_damage)
		grid.get_node("AttIcon").show()
		grid.get_node("RangeLabel").show()
		grid.get_node("RangeLabel").text = str(data.attack_range)
		grid.get_node("RangeIcon").show()
	else:
		grid.get_node("SpecialLabel").show()
		grid.get_node("SpecialIcon").show()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton
		if mb_event.button_index == 1:
			if draggable and mb_event.pressed and not dragging:
				dragging = true
				rotation = -0.5 # radians
				scale = Vector2(0.5, 0.5)
			elif not mb_event.pressed and dragging:
				dragging = false
				position = hand_position
				rotation = 0.0
				scale = Vector2.ONE
				dropped_card.emit(self)
