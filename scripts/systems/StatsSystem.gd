# Corehold
# File: scripts/systems/StatsSystem.gd
# Purpose: Run statistics recording and history tracking
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
## Stats tracking system. Records run statistics and history.

var run_history: Array = []
var _damage_taken_sources: Dictionary = {}
var _death_cause: String = ""

func record_damage_taken(source: String, amount: int) -> void:
	if not _damage_taken_sources.has(source):
		_damage_taken_sources[source] = 0
	_damage_taken_sources[source] += amount

func record_death(cause: String) -> void:
	_death_cause = cause

func finalize_run() -> void:
	var entry: Dictionary = {
		"wave": RunState.wave_number,
		"kills": RunState.kills,
		"salvage": RunState.salvage,
		"time": RunState.run_time,
		"death_cause": _death_cause,
		"damage_by_source": _damage_taken_sources.duplicate(),
		"upgrades": RunState.active_upgrades.duplicate(),
		"timestamp": Time.get_datetime_string_from_system()
	}
	run_history.append(entry)
	if run_history.size() > 10:
		run_history.pop_front()
	_reset_run_tracking()

func _reset_run_tracking() -> void:
	_damage_taken_sources.clear()
	_death_cause = ""

func get_history() -> Array:
	return run_history

func load_history(data: Array) -> void:
	run_history = data

func get_last_run() -> Dictionary:
	if run_history.is_empty():
		return {}
	return run_history[-1]

func get_top_killers() -> Array:
	var sorted: Array = []
	for source in _damage_taken_sources:
		sorted.append({"source": source, "damage": _damage_taken_sources[source]})
	sorted.sort_custom(func(a, b): return a["damage"] > b["damage"])
	return sorted

func get_death_cause() -> String:
	return _death_cause
