# Corehold
# File: scripts/core/GameState.gd
# Purpose: Global game state singleton that persists between scenes
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

extends Node
## Global game state singleton. Persists between scenes.
## Attach as an Autoload singleton in project.godot.

var total_salvage: int = 0
var runs_completed: int = 0
var best_wave: int = 0
var best_time: float = 0.0
var best_salvage: int = 0

func _ready() -> void:
	pass

func record_run(wave: int, kills: int, run_salvage: int, time_survived: float) -> void:
	runs_completed += 1
	total_salvage += run_salvage
	if wave > best_wave:
		best_wave = wave
	if time_survived > best_time:
		best_time = time_survived
	if run_salvage > best_salvage:
		best_salvage = run_salvage
