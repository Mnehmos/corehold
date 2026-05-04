# Corehold
# File: scripts/systems/ShieldSystem.gd
# Purpose: Shield absorption, regeneration, and break feedback
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
## Shield system. Manages shield absorption, regeneration, and break feedback.

var shield: float = 0.0
var max_shield: float = Constants.DEFAULT_SHIELD
var _time_since_hit: float = 0.0
var is_broken: bool = false

func _ready() -> void:
	shield = max_shield
	RunState.shield = shield
	RunState.max_shield = max_shield

func process_shield(delta: float) -> void:
	if shield < max_shield and not is_broken:
		_time_since_hit += delta
		if _time_since_hit >= Constants.SHIELD_REGEN_DELAY:
			shield = minf(max_shield, shield + Constants.SHIELD_REGEN_RATE * delta)
			RunState.shield = shield
			EventBus.shield_changed.emit(shield, max_shield)

func absorb_damage(amount: int) -> int:
	var remaining: int = amount
	if shield > 0:
		var absorbed: float = minf(shield, float(amount))
		shield -= absorbed
		remaining -= int(absorbed)
		_time_since_hit = 0.0
		if shield <= 0:
			is_broken = true
		EventBus.shield_changed.emit(shield, max_shield)
	RunState.shield = shield
	return remaining

func restore(amount: float) -> void:
	shield = minf(max_shield, shield + amount)
	is_broken = false
	RunState.shield = shield
	EventBus.shield_changed.emit(shield, max_shield)
