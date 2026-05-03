# Corehold
# File: scripts/core/RunState.gd
# Purpose: Per-run state that resets at the start of each run
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
## Per-run state. Reset at the start of each run.
## Attach as an Autoload singleton in project.godot.

var wave_number: int = 0
var kills: int = 0
var salvage: int = 0
var run_time: float = 0.0
var tower_hp: int = 100
var tower_max_hp: int = 100
var heat: float = 0.0
var max_heat: float = 100.0
var power_used: float = 0.0
var power_capacity: float = 100.0
var shield: float = 0.0
var max_shield: float = 50.0
var active_upgrades: Array[String] = []

func reset() -> void:
	wave_number = 0
	kills = 0
	salvage = 0
	run_time = 0.0
	tower_hp = 100
	tower_max_hp = 100
	heat = 0.0
	max_heat = 100.0
	power_used = 0.0
	power_capacity = 100.0
	shield = 0.0
	max_shield = 50.0
	active_upgrades.clear()
