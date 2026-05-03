# Corehold
# File: scripts/core/Constants.gd
# Purpose: Game-wide constants and tuning values
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

class_name Constants
## Game-wide constants and tuning values.

# Arena
const ARENA_WIDTH: int = 1280
const ARENA_HEIGHT: int = 720
const TOWER_CENTER: Vector2 = Vector2(640, 360)

# Tower defaults
const DEFAULT_TOWER_HP: int = 100
const DEFAULT_TOWER_RANGE: float = 300.0
const DEFAULT_FIRE_RATE: float = 2.0
const DEFAULT_DAMAGE: int = 10
const DEFAULT_PROJECTILE_SPEED: float = 400.0

# Heat
const DEFAULT_MAX_HEAT: float = 100.0
const HEAT_DECAY_RATE: float = 5.0
const OVERHEAT_THRESHOLD: float = 0.9
const OVERHEAT_PENALTY: float = 0.5

# Power
const DEFAULT_POWER_CAPACITY: float = 100.0

# Shield
const DEFAULT_SHIELD: float = 50.0
const SHIELD_REGEN_DELAY: float = 3.0
const SHIELD_REGEN_RATE: float = 5.0

# Salvage
const SALVAGE_PER_KILL_MULTIPLIER: float = 1.0
const WAVE_COMPLETION_BONUS: int = 10
const BOSS_KILL_BONUS: int = 50

# Waves
const BOSS_INTERVAL: int = 10
const WAVE_REST_TIME: float = 5.0

# Damage types
enum DamageType {
	KINETIC,
	THERMAL,
	ELECTRIC,
	EXPLOSIVE,
}

# Targeting modes
enum TargetingMode {
	NEAREST,
	LOWEST_HP,
	HIGHEST_HP,
	FASTEST,
	BOSS_PRIORITY,
}
