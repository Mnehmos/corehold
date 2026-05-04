# Corehold
# File: scripts/combat/Projectile.gd
# Purpose: Projectile entity handling movement, collision, and damage application
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

extends Node2D
## Projectile entity. Handles movement, collision, and damage application.

var damage: int = 10
var speed: float = 400.0
var direction: Vector2 = Vector2.UP
var max_range: float = 400.0
var _distance_traveled: float = 0.0

@onready var _hitbox: Area2D = $Hitbox

func _ready() -> void:
	if _hitbox:
		_hitbox.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	var movement: Vector2 = direction * speed * delta
	global_position += movement
	_distance_traveled += movement.length()
	if _distance_traveled >= max_range:
		queue_free()

func setup(proj_damage: int, proj_speed: float, proj_direction: Vector2, proj_range: float) -> void:
	damage = proj_damage
	speed = proj_speed
	direction = proj_direction.normalized()
	max_range = proj_range
	rotation = direction.angle()

func _on_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent and parent.is_in_group("enemies") and parent.has_method("take_damage"):
		parent.take_damage(damage)
		queue_free()
