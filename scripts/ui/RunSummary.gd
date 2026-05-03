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
	_populate_stats()

func _populate_stats() -> void:
	var vbox: VBoxContainer = $CenterContainer/VBoxContainer
	vbox.get_node("WaveLabel").text = "Wave Reached: %d" % RunState.wave_number
	vbox.get_node("KillsLabel").text = "Enemies Killed: %d" % RunState.kills
	vbox.get_node("TimeLabel").text = "Time Survived: %s" % _format_time(RunState.run_time)
	vbox.get_node("SalvageLabel").text = "Salvage Earned: %d" % RunState.salvage

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]
