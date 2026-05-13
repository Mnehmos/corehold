# Corehold
# File: scripts/combat/TargetingSystem.gd
# Purpose: Targeting system determining which enemy the tower should fire at
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
## Targeting system. Determines which enemy the tower should fire at.

var current_mode: int = Constants.TargetingMode.NEAREST
var mode_names: PackedStringArray = ["Nearest", "Lowest HP", "Highest HP", "Fastest", "Boss Priority"]

func set_mode(mode: int) -> void:
	if mode >= 0 and mode < mode_names.size():
		current_mode = mode

func cycle_mode() -> void:
	current_mode = (current_mode + 1) % mode_names.size()

func get_mode_name() -> String:
	if current_mode < mode_names.size():
		return mode_names[current_mode]
	return "Nearest"

func pick_target(enemies: Array[Node2D], tower_pos: Vector2) -> Node2D:
	var valid_enemies: Array[Node2D] = []
	for e in enemies:
		if is_instance_valid(e):
			valid_enemies.append(e)
	if valid_enemies.is_empty():
		return null
	match current_mode:
		Constants.TargetingMode.NEAREST:
			return _pick_nearest(valid_enemies, tower_pos)
		Constants.TargetingMode.LOWEST_HP:
			return _pick_lowest_hp(valid_enemies)
		Constants.TargetingMode.HIGHEST_HP:
			return _pick_highest_hp(valid_enemies)
		Constants.TargetingMode.FASTEST:
			return _pick_fastest(valid_enemies)
		Constants.TargetingMode.BOSS_PRIORITY:
			return _pick_boss_priority(valid_enemies, tower_pos)
		_:
			return _pick_nearest(valid_enemies, tower_pos)

func _pick_nearest(enemies: Array[Node2D], tower_pos: Vector2) -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for e in enemies:
		var dist: float = tower_pos.distance_to(e.global_position)
		if dist < best_dist:
			best_dist = dist
			best = e
	return best

func _pick_lowest_hp(enemies: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_hp: int = 999999
	for e in enemies:
		if e.hp < best_hp:
			best_hp = e.hp
			best = e
	return best

func _pick_highest_hp(enemies: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_hp: int = 0
	for e in enemies:
		if e.hp > best_hp:
			best_hp = e.hp
			best = e
	return best

func _pick_fastest(enemies: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_speed: float = 0.0
	for e in enemies:
		if e.speed > best_speed:
			best_speed = e.speed
			best = e
	return best

func _pick_boss_priority(enemies: Array[Node2D], tower_pos: Vector2) -> Node2D:
	var bosses: Array[Node2D] = []
	for e in enemies:
		if e.is_in_group("bosses"):
			bosses.append(e)
	if not bosses.is_empty():
		return _pick_nearest(bosses, tower_pos)
	return _pick_nearest(enemies, tower_pos)
