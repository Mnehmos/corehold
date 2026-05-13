# Corehold
# File: scripts/combat/WeaponSystem.gd
# Purpose: Weapon system managing active weapon, fire rate, and projectile spawning
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
## Weapon system. Manages active weapon, fire rate, and projectile spawning.

var weapon_id: String = "machine_gun"
var weapon_name: String = "Machine Gun"
var damage: int = 8
var fire_rate: float = 6.0
var weapon_range: float = 280.0
var heat_per_shot: float = 2.0
var power_draw: float = 10.0
var projectile_speed: float = 500.0
var damage_type: String = "kinetic"
var pierce_count: int = 0
var crit_chance: float = 0.0
var crit_multiplier: float = 2.0

func equip_weapon(weapon_data: Dictionary) -> void:
	weapon_id = weapon_data.get("id", "machine_gun")
	weapon_name = weapon_data.get("name", "Machine Gun")
	damage = int(weapon_data.get("damage", 8))
	fire_rate = weapon_data.get("fire_rate", 6.0)
	weapon_range = weapon_data.get("range", 280.0)
	heat_per_shot = weapon_data.get("heat_per_shot", 2.0)
	power_draw = weapon_data.get("power_draw", 10.0)
	projectile_speed = weapon_data.get("projectile_speed", 500.0)
	damage_type = weapon_data.get("damage_type", "kinetic")

func apply_upgrade_modifiers(upgrade_system: Node) -> void:
	damage = int(damage * (1.0 + upgrade_system.get_stat_modifier("damage_multiplier")))
	fire_rate *= (1.0 + upgrade_system.get_stat_modifier("fire_rate_multiplier"))
	weapon_range += upgrade_system.get_stat_modifier("tower_range")
	heat_per_shot += upgrade_system.get_stat_modifier("heat_per_shot_bonus")
	crit_chance += upgrade_system.get_stat_modifier("crit_chance")
	pierce_count += int(upgrade_system.get_stat_modifier("pierce_count"))

func calculate_damage(target_is_boss: bool, upgrade_system: Node) -> int:
	var dmg: int = damage
	if target_is_boss:
		dmg = int(dmg * (1.0 + upgrade_system.get_stat_modifier("boss_damage_multiplier")))
	if crit_chance > 0.0 and randf() < crit_chance:
		dmg = int(dmg * crit_multiplier)
	return dmg
