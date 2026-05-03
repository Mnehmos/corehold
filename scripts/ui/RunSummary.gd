# Corehold
# File: scripts/ui/RunSummary.gd
# Purpose: Run summary screen showing results with restart and menu options
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
## Run summary screen. Shows run results and offers restart/menu options.

func _ready() -> void:
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$CenterContainer/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
