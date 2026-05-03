# Corehold
# File: scripts/ui/Game.gd
# Purpose: Game scene controller managing the active run
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

extends Node2D
## Game scene controller. Manages the active run.

func _ready() -> void:
	RunState.reset()
	EventBus.run_started.emit()
	$HUD/EndRunButton.pressed.connect(_on_end_run_pressed)
	_update_hud()

func _process(delta: float) -> void:
	RunState.run_time += delta
	_update_hud()

func _on_end_run_pressed() -> void:
	_end_run()

func _end_run() -> void:
	EventBus.run_ended.emit(
		RunState.wave_number,
		RunState.kills,
		RunState.salvage,
		RunState.run_time
	)
	GameState.record_run(
		RunState.wave_number,
		RunState.kills,
		RunState.salvage,
		RunState.run_time
	)
	get_tree().change_scene_to_file("res://scenes/RunSummary.tscn")

func _update_hud() -> void:
	var hud_panel: HBoxContainer = $HUD/HUDPanel
	hud_panel.get_node("HPLabel").text = "HP: %d" % RunState.tower_hp
	hud_panel.get_node("WaveLabel").text = "Wave: %d" % RunState.wave_number
	hud_panel.get_node("KillsLabel").text = "Kills: %d" % RunState.kills
	hud_panel.get_node("TimerLabel").text = _format_time(RunState.run_time)

func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]
