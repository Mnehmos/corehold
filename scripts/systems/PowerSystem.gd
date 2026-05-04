# Corehold
# File: scripts/systems/PowerSystem.gd
# Purpose: Tower power capacity and module power draw management
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
## Power system. Manages tower power capacity and module power draw.

var power_used: float = 10.0
var power_capacity: float = Constants.DEFAULT_POWER_CAPACITY

func _ready() -> void:
	RunState.power_used = power_used
	RunState.power_capacity = power_capacity

func add_draw(amount: float) -> bool:
	if power_used + amount > power_capacity:
		return false
	power_used += amount
	_sync_state()
	return true

func remove_draw(amount: float) -> void:
	power_used = maxf(0.0, power_used - amount)
	_sync_state()

func has_capacity(amount: float) -> bool:
	return power_used + amount <= power_capacity

func _sync_state() -> void:
	RunState.power_used = power_used
	RunState.power_capacity = power_capacity
	EventBus.power_changed.emit(power_used, power_capacity)
