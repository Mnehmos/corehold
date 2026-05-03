extends Node
## Global event bus. Provides decoupled signals for game-wide events.
## Attach as an Autoload singleton in project.godot.

signal run_started
signal run_ended(wave_reached: int, kills: int, salvage: int, time_survived: float)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_killed(enemy_type: String, reward: int)
signal enemy_spawned(enemy_type: String)
signal tower_damaged(amount: int, source: String)
signal tower_healed(amount: int)
signal upgrade_selected(upgrade_id: String)
signal heat_changed(current: float, max_heat: float)
signal power_changed(used: float, capacity: float)
signal shield_changed(current: float, max_shield: float)
signal boss_spawned(boss_id: String)
signal boss_defeated(boss_id: String, reward: int)
