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

## Loaded game data available to all systems.
var weapons_data: Array = []
var enemies_data: Array = []
var upgrades_data: Array = []
var waves_data: Dictionary = {}

func _ready() -> void:
	_load_game_data()

func _load_game_data() -> void:
	weapons_data = JsonLoader.load_data_array("weapons.json")
	enemies_data = JsonLoader.load_data_array("enemies.json")
	upgrades_data = JsonLoader.load_data_array("upgrades.json")
	waves_data = JsonLoader.load_json("res://data/waves.json")
	_validate_loaded_data()

func _validate_loaded_data() -> void:
	if weapons_data.is_empty():
		push_error("GameState: weapons.json loaded empty — no weapons available.")
	if enemies_data.is_empty():
		push_error("GameState: enemies.json loaded empty — no enemies available.")
	if weapons_data.size() > 0:
		print("GameState: Loaded %d weapons." % weapons_data.size())
	if enemies_data.size() > 0:
		print("GameState: Loaded %d enemies." % enemies_data.size())
	if upgrades_data.size() > 0:
		print("GameState: Loaded %d upgrades." % upgrades_data.size())
	if not waves_data.is_empty():
		var wave_count: int = waves_data.get("waves", []).size()
		print("GameState: Loaded %d wave definitions." % wave_count)

func get_weapon_by_id(weapon_id: String) -> Dictionary:
	for weapon in weapons_data:
		if weapon.get("id", "") == weapon_id:
			return weapon
	push_warning("GameState: Weapon '%s' not found." % weapon_id)
	return {}

func get_enemy_by_id(enemy_id: String) -> Dictionary:
	for enemy in enemies_data:
		if enemy.get("id", "") == enemy_id:
			return enemy
	push_warning("GameState: Enemy '%s' not found." % enemy_id)
	return {}

func record_run(wave: int, kills: int, run_salvage: int, time_survived: float) -> void:
	runs_completed += 1
	total_salvage += run_salvage
	if wave > best_wave:
		best_wave = wave
	if time_survived > best_time:
		best_time = time_survived
	if run_salvage > best_salvage:
		best_salvage = run_salvage
