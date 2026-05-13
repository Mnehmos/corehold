# Corehold
# File: scripts/systems/UpgradeSystem.gd
# Purpose: Upgrade loading from JSON and stat modifier application
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
## Upgrade system. Loads upgrade definitions and applies stat modifiers.

var applied_upgrades: Array[String] = []
var _available_pool: Array = []

func _ready() -> void:
	_build_available_pool()

func _build_available_pool() -> void:
	_available_pool.clear()
	for upgrade in GameState.upgrades_data:
		if not upgrade.has("id"):
			continue
		if upgrade["id"] in applied_upgrades:
			continue
		_available_pool.append(upgrade)

func get_random_choices(count: int = 3) -> Array:
	var pool: Array = _available_pool.duplicate()
	pool.shuffle()
	var choices: Array = []
	var max_rerolls: int = 10
	for i in mini(count, pool.size()):
		choices.append(pool[i])
	while choices.size() < count and max_rerolls > 0:
		max_rerolls -= 1
		choices.append({"id": "reinforced_hull", "name": "Reinforced Hull", "description": "+30 max HP.", "category": "defense", "rarity": "common", "effects": [{"stat": "max_hp", "value": 30, "operation": "add"}], "tags": ["defense", "hp"]})
	return choices

func apply_upgrade(upgrade_id: String) -> void:
	var upgrade: Dictionary = _find_upgrade(upgrade_id)
	if upgrade.is_empty():
		push_warning("UpgradeSystem: Upgrade '%s' not found." % upgrade_id)
		return
	applied_upgrades.append(upgrade_id)
	RunState.active_upgrades.append(upgrade_id)
	var effects: Array = upgrade.get("effects", [])
	for effect in effects:
		_apply_effect(effect)
	EventBus.upgrade_selected.emit(upgrade_id)
	_build_available_pool()

func _find_upgrade(upgrade_id: String) -> Dictionary:
	for upgrade in GameState.upgrades_data:
		if upgrade.get("id", "") == upgrade_id:
			return upgrade
	return {}

func _apply_effect(effect: Dictionary) -> void:
	var stat: String = effect.get("stat", "")
	var value: float = effect.get("value", 0.0)
	var operation: String = effect.get("operation", "add")
	match stat:
		"max_hp":
			if operation == "add":
				RunState.tower_max_hp += int(value)
				RunState.tower_hp = mini(RunState.tower_hp + int(value), RunState.tower_max_hp)
		"damage_multiplier":
			pass
		"fire_rate_multiplier":
			pass
		"tower_range":
			pass
		"max_heat":
			RunState.max_heat += value
		"max_shield":
			RunState.max_shield += value
		"power_capacity":
			RunState.power_capacity += value
		"heat_decay_multiplier":
			pass
		"heat_per_shot_bonus":
			pass
		"salvage_multiplier":
			pass
		"shield_regen_multiplier":
			pass
		"hp_regen":
			pass
		"damage_reduction":
			pass
		"crit_chance":
			pass
		"pierce_count":
			pass

func get_stat_modifier(stat_name: String) -> float:
	var total: float = 0.0
	for uid in applied_upgrades:
		var upgrade: Dictionary = _find_upgrade(uid)
		for effect in upgrade.get("effects", []):
			if effect.get("stat", "") == stat_name:
				var val: float = effect.get("value", 0.0)
				var op: String = effect.get("operation", "add")
				if op == "add":
					total += val
				elif op == "multiply":
					total *= val
				elif op == "set":
					total = val
	return total

func has_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in applied_upgrades

func get_applied_count() -> int:
	return applied_upgrades.size()
