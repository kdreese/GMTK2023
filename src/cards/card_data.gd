## A data structure for cards.
class_name CardData
extends Resource


# TODO: is there a better way? These aren't synced automatically with the export.
const SHOW_HEALTH_FLAG = 1
const SHOW_MOVEMENT_FLAG = 2
const SHOW_DAMAGE_FLAG = 4
const SHOW_RANGE_FLAG = 8


@export_group("Basic Info")
@export var name: String ## The name of the card.
@export_multiline var description: String ## A detailed description
@export_multiline var special_effect: String ## Tooltip effect description
@export var icon: Texture2D ## The icon for this card.
@export var rank: int ## The power rank of this card.
@export_enum("Attack", "Defense") var card_role: String ## The role of this card.
@export_group("Card Stats")
@export var health: int
@export var movement: int
@export var damage: int
@export var att_range: int
@export var special: bool
## Flags to indicate whether various stats should be shown.
@export_flags("Health", "Movement", "Damage", "Range") var info_show_flags: int = 0
@export var stat_string_overrides: Dictionary = {
	"health": "",
	"movement": "",
	"damage": "",
	"att_range": "",
}
@export_group("Script Data")
@export_file() var effect_script ## A path to the script run by this card.
@export var extra_data: Array[String] ## Extra data to be accessed by the script.
