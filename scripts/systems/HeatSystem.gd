# Corehold
# File: scripts/systems/HeatSystem.gd
# Purpose: Tower heat management including generation, dissipation, and overheating
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
## Heat system. Manages tower heat generation, dissipation, and overheating.

var heat: float = 0.0
var max_heat: float = Constants.DEFAULT_MAX_HEAT
var heat_per_shot: float = 2.0
var is_overheated: bool = false
var _overheat_cooldown: float = 0.0
var _overheat_penalty_duration: float = 2.0

func _ready() -> void:
	RunState.heat = 0.0
	RunState.max_heat = max_heat

func process_heat(delta: float) -> void:
	if is_overheated:
		_overheat_cooldown -= delta
		if _overheat_cooldown <= 0.0:
			is_overheated = false
	heat = maxf(0.0, heat - Constants.HEAT_DECAY_RATE * delta)
	RunState.heat = heat
	RunState.max_heat = max_heat
	EventBus.heat_changed.emit(heat, max_heat)

func add_heat(amount: float) -> bool:
	if is_overheated:
		return false
	heat += amount
	if heat >= max_heat * Constants.OVERHEAT_THRESHOLD:
		_trigger_overheat()
	return not is_overheated

func _trigger_overheat() -> void:
	is_overheated = true
	_overheat_cooldown = _overheat_penalty_duration
	heat = max_heat

func get_fire_rate_multiplier() -> float:
	if is_overheated:
		return Constants.OVERHEAT_PENALTY
	var heat_ratio: float = heat / max_heat
	if heat_ratio > 0.7:
		return 1.0 - (heat_ratio - 0.7) * 0.5
	return 1.0
