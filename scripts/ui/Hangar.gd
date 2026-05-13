# Corehold
# File: scripts/ui/Hangar.gd
# Purpose: Between-run progression screen for salvage spending
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
## Hangar screen. Between-run progression and salvage spending.

func _ready() -> void:
	$CenterContainer/VBoxContainer/StartRunButton.pressed.connect(_on_start_run)
	$CenterContainer/VBoxContainer/MenuButton.pressed.connect(_on_menu)
	_refresh_display()

func _refresh_display() -> void:
	_update_salvage_display()
	_update_upgrade_list()

func _update_salvage_display() -> void:
	$CenterContainer/VBoxContainer/SalvageLabel.text = "Salvage: %d" % GameState.total_salvage

func _update_upgrade_list() -> void:
	var list: VBoxContainer = $CenterContainer/VBoxContainer/UpgradeList
	for child in list.get_children():
		child.queue_free()
	var progression: Node = _get_progression()
	if progression == null:
		return
	var available: Array = progression.get_available_permanent_upgrades()
	for upgrade in available:
		var btn: Button = Button.new()
		btn.text = "%s (%d salvage) - %s" % [upgrade.get("name", "???"), upgrade.get("cost", 0), upgrade.get("description", "")]
		btn.custom_minimum_size = Vector2(400, 36)
		var upgrade_id: String = upgrade.get("id", "")
		btn.pressed.connect(_on_purchase.bind(upgrade_id))
		list.add_child(btn)
	var all: Array = progression.get_all_permanent_upgrades()
	for upgrade in all:
		if progression.is_unlocked(upgrade.get("id", "")):
			var lbl: Label = Label.new()
			lbl.text = "  [OWNED] %s" % upgrade.get("name", "???")
			lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
			list.add_child(lbl)

func _on_purchase(upgrade_id: String) -> void:
	var progression: Node = _get_progression()
	if progression and progression.purchase_upgrade(upgrade_id):
		_refresh_display()

func _get_progression() -> Node:
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		return gs.get_node_or_null("ProgressionSystem")
	return null

func _on_start_run() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
