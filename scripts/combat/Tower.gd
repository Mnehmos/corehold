# Corehold
# File: scripts/combat/Tower.gd
# Purpose: Tower entity handling HP, rotation, targeting, and weapon firing
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
## Tower entity. Handles HP, rotation, targeting, and weapon firing.

signal died

@export var max_hp: int = Constants.DEFAULT_TOWER_HP
@export var tower_range: float = Constants.DEFAULT_TOWER_RANGE
@export var fire_rate: float = Constants.DEFAULT_FIRE_RATE
@export var damage: int = Constants.DEFAULT_DAMAGE
@export var projectile_speed: float = Constants.DEFAULT_PROJECTILE_SPEED

var hp: int = 0
var _fire_cooldown: float = 0.0
var _target: Node2D = null
var _enemies_in_range: Array[Node2D] = []

@onready var _barrel: Node2D = $BarrelPivot
@onready var _range_area: Area2D = $RangeArea
@onready var _body: ColorRect = $TowerBody

func _ready() -> void:
	add_to_group("tower")
	hp = max_hp
	if _range_area:
		_range_area.area_entered.connect(_on_area_entered)
		_range_area.area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	_update_target()
	_rotate_toward_target()
	_fire_cooldown -= delta
	_try_fire()

func take_damage(amount: int, source: String = "") -> void:
	hp = max(0, hp - amount)
	EventBus.tower_damaged.emit(amount, source)
	RunState.tower_hp = hp
	if hp <= 0:
		died.emit()
		queue_free()

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	RunState.tower_hp = hp
	EventBus.tower_healed.emit(amount)

func get_target() -> Node2D:
	return _target

func _update_target() -> void:
	_enemies_in_range = _enemies_in_range.filter(func(e): return is_instance_valid(e))
	if _enemies_in_range.is_empty():
		_target = null
		return
	var best: Node2D = null
	var best_dist: float = INF
	for enemy in _enemies_in_range:
		var dist: float = global_position.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	_target = best

func _rotate_toward_target() -> void:
	if _target == null or _barrel == null:
		return
	var angle: float = global_position.direction_to(_target.global_position).angle()
	_barrel.rotation = angle

func _on_area_entered(area: Area2D) -> void:
	var owner_node: Node2D = _get_enemy_owner(area)
	if owner_node and owner_node.is_in_group("enemies"):
		_enemies_in_range.append(owner_node)

func _on_area_exited(area: Area2D) -> void:
	var owner_node: Node2D = _get_enemy_owner(area)
	_enemies_in_range.erase(owner_node)

func _get_enemy_owner(area: Area2D) -> Node2D:
	var parent: Node = area.get_parent()
	if parent is Node2D:
		return parent as Node2D
	return null

func _try_fire() -> void:
	if _target == null or _fire_cooldown > 0.0:
		return
	_fire_cooldown = 1.0 / fire_rate
	_spawn_projectile()

func _spawn_projectile() -> void:
	var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
	var projectile: Node2D = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	var direction: Vector2 = global_position.direction_to(_target.global_position)
	projectile.global_position = global_position
	projectile.setup(damage, projectile_speed, direction, tower_range)
