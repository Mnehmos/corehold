# Corehold
# File: scripts/ui/UpgradePanel.gd
# Purpose: Upgrade draft panel showing 3 upgrade cards during run
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

extends Control
## Upgrade draft panel. Shows 3 upgrade cards during run.

signal upgrade_selected(upgrade_id: String)

var _choices: Array = []
var _is_visible: bool = false

func _ready() -> void:
	visible = false
	_set_card_visible(1, false)
	_set_card_visible(2, false)
	_set_card_visible(3, false)

func show_choices(choices: Array) -> void:
	_choices = choices
	_is_visible = true
	visible = true
	get_tree().paused = true
	for i in range(3):
		if i < choices.size():
			_setup_card(i + 1, choices[i])
		else:
			_set_card_visible(i + 1, false)

func _setup_card(index: int, data: Dictionary) -> void:
	_set_card_visible(index, true)
	var card: VBoxContainer = get_node("CenterContainer/VBoxContainer/Card%d" % index)
	card.get_node("NameLabel").text = data.get("name", "???")
	card.get_node("DescLabel").text = data.get("description", "")
	card.get_node("RarityLabel").text = data.get("rarity", "common").to_upper()
	card.get_node("CatLabel").text = data.get("category", "")
	var color: Color = _rarity_color(data.get("rarity", "common"))
	card.get_node("RarityLabel").add_theme_color_override("font_color", color)

func _set_card_visible(index: int, vis: bool) -> void:
	var card_path: String = "CenterContainer/VBoxContainer/Card%d" % index
	if has_node(card_path):
		get_node(card_path).visible = vis

func _on_card_1_pressed() -> void:
	_select(0)

func _on_card_2_pressed() -> void:
	_select(1)

func _on_card_3_pressed() -> void:
	_select(2)

func _select(index: int) -> void:
	if index >= _choices.size():
		return
	var upgrade_id: String = _choices[index].get("id", "")
	upgrade_selected.emit(upgrade_id)
	_close()

func _close() -> void:
	_is_visible = false
	visible = false
	get_tree().paused = false

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"common": return Color.WHITE
		"uncommon": return Color(0.3, 0.9, 0.3)
		"rare": return Color(0.4, 0.6, 1.0)
		"legendary": return Color(1.0, 0.7, 0.1)
		_: return Color.WHITE
