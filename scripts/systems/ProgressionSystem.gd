# Corehold
# File: scripts/systems/ProgressionSystem.gd
# Purpose: Permanent unlocks and meta progression management
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise -> Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

extends Node
## Progression system. Manages permanent unlocks and meta progression.

var unlocked_ids: Array[String] = []
var _permanent_upgrades: Array = []

func _ready() -> void:
	_load_permanent_definitions()

func _load_permanent_definitions() -> void:
	_permanent_upgrades = []
	for upgrade in GameState.upgrades_data:
		if upgrade.has("cost"):
			_permanent_upgrades.append(upgrade)

func get_available_permanent_upgrades() -> Array:
	var available: Array = []
	for upgrade in _permanent_upgrades:
		var uid: String = upgrade.get("id", "")
		if uid in unlocked_ids:
			continue
		var prereq: String = upgrade.get("prerequisite", "")
		if prereq != "" and not prereq in unlocked_ids:
			continue
		if upgrade.get("cost", 0) > GameState.total_salvage:
			continue
		available.append(upgrade)
	return available

func get_all_permanent_upgrades() -> Array:
	return _permanent_upgrades

func purchase_upgrade(upgrade_id: String) -> bool:
	var upgrade: Dictionary = _find_permanent(upgrade_id)
	if upgrade.is_empty():
		return false
	var cost: int = upgrade.get("cost", 0)
	if GameState.total_salvage < cost:
		return false
	var prereq: String = upgrade.get("prerequisite", "")
	if prereq != "" and not prereq in unlocked_ids:
		return false
	if upgrade_id in unlocked_ids:
		return false
	GameState.total_salvage -= cost
	unlocked_ids.append(upgrade_id)
	return true

func is_unlocked(upgrade_id: String) -> bool:
	return upgrade_id in unlocked_ids

func get_unlocked_ids() -> Array:
	return unlocked_ids

func load_unlocked(ids: Array) -> void:
	unlocked_ids.clear()
	for id in ids:
		unlocked_ids.append(id)

func apply_permanent_bonuses() -> void:
	for uid in unlocked_ids:
		var upgrade: Dictionary = _find_permanent(uid)
		for effect in upgrade.get("effects", []):
			var stat: String = effect.get("stat", "")
			var value: float = effect.get("value", 0.0)
			match stat:
				"max_hp":
					RunState.tower_max_hp += int(value)
				"max_shield":
					RunState.max_shield += value
				"max_heat":
					RunState.max_heat += value
				"power_capacity":
					RunState.power_capacity += value
				"tower_range":
					pass
				"damage":
					pass
				"fire_rate_multiplier":
					pass
				"salvage_multiplier":
					pass
				"shield_regen_rate":
					pass
				"heat_decay_multiplier":
					pass
				"crit_chance":
					pass
				"boss_damage_multiplier":
					pass
				"starting_salvage":
					RunState.salvage += int(value)

func _find_permanent(upgrade_id: String) -> Dictionary:
	for upgrade in _permanent_upgrades:
		if upgrade.get("id", "") == upgrade_id:
			return upgrade
	return {}
