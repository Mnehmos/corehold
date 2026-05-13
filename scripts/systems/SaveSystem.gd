# Corehold
# File: scripts/systems/SaveSystem.gd
# Purpose: Player progression persistence to disk
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
## Save system. Persists player progression to disk.

const SAVE_PATH: String = "user://save.json"

func auto_save() -> void:
	var data: Dictionary = {
		"version": 1,
		"total_salvage": GameState.total_salvage,
		"runs_completed": GameState.runs_completed,
		"best_wave": GameState.best_wave,
		"best_time": GameState.best_time,
		"best_salvage": GameState.best_salvage,
		"unlocked_permanent_upgrades": _get_unlocked_permanent_upgrades(),
		"run_history": _get_run_history(),
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: Failed to open save file for writing.")
		return
	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: Failed to open save file for reading.")
		return false
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		push_error("SaveSystem: Corrupt save file. Starting fresh.")
		return false
	var data: Dictionary = json.get_data()
	if data.is_empty():
		return false
	GameState.total_salvage = int(data.get("total_salvage", 0))
	GameState.runs_completed = int(data.get("runs_completed", 0))
	GameState.best_wave = int(data.get("best_wave", 0))
	GameState.best_time = float(data.get("best_time", 0.0))
	GameState.best_salvage = int(data.get("best_salvage", 0))
	_load_permanent_upgrades(data.get("unlocked_permanent_upgrades", []))
	_load_run_history(data.get("run_history", []))
	return true

func _get_unlocked_permanent_upgrades() -> Array:
	var node: Node = get_node_or_null("/root/GameState/ProgressionSystem")
	if node and node.has_method("get_unlocked_ids"):
		return node.get_unlocked_ids()
	return []

func _get_run_history() -> Array:
	var node: Node = get_node_or_null("/root/GameState/StatsSystem")
	if node and node.has_method("get_history"):
		return node.get_history()
	return []

func _load_permanent_upgrades(ids: Array) -> void:
	var node: Node = get_node_or_null("/root/GameState/ProgressionSystem")
	if node and node.has_method("load_unlocked"):
		node.load_unlocked(ids)

func _load_run_history(history: Array) -> void:
	var node: Node = get_node_or_null("/root/GameState/StatsSystem")
	if node and node.has_method("load_history"):
		node.load_history(history)
