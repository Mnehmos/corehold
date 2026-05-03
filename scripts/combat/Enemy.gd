# Corehold
# File: scripts/combat/Enemy.gd
# Purpose: Enemy entity handling movement toward tower, HP, damage, and death
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
## Enemy entity. Handles movement toward tower, HP, damage, and death.

signal died(enemy: Node2D)

var enemy_id: String = ""
var hp: int = 15
var max_hp: int = 15
var speed: float = 120.0
var damage: int = 5
var salvage_reward: int = 2
var enemy_color: Color = Color.GREEN
var enemy_size: float = 8.0
var _tower_position: Vector2 = Vector2.ZERO
var _attack_cooldown: float = 0.0
var _attack_interval: float = 1.0

@onready var _body: ColorRect = $EnemyBody
@onready var _hitbox: Area2D = $Hitbox

func _ready() -> void:
	add_to_group("enemies")
	_update_visual()

func setup(data: Dictionary, tower_pos: Vector2) -> void:
	enemy_id = data.get("id", "unknown")
	hp = data.get("hp", 15)
	max_hp = hp
	speed = data.get("speed", 120.0)
	damage = data.get("damage", 5)
	salvage_reward = data.get("salvage_reward", 2)
	enemy_color = Color.from_string(data.get("color", "#55ff55"), Color.GREEN)
	enemy_size = data.get("size", 8.0)
	_tower_position = tower_pos
	_update_visual()

func _process(delta: float) -> void:
	if _tower_position == Vector2.ZERO:
		return
	var direction: Vector2 = global_position.direction_to(_tower_position)
	var distance: float = global_position.distance_to(_tower_position)
	if distance > 24.0:
		global_position += direction * speed * delta
	else:
		_attack_cooldown -= delta
		if _attack_cooldown <= 0.0:
			_attack_tower()
			_attack_cooldown = _attack_interval

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_die()

func _attack_tower() -> void:
	var towers: Array[Node] = get_tree().get_nodes_in_group("tower")
	if towers.size() > 0:
		var tower: Node2D = towers[0]
		if tower.has_method("take_damage"):
			tower.take_damage(damage, enemy_id)

func _die() -> void:
	EventBus.enemy_killed.emit(enemy_id, salvage_reward)
	RunState.kills += 1
	RunState.salvage += salvage_reward
	died.emit(self)
	queue_free()

func _update_visual() -> void:
	if _body:
		_body.color = enemy_color
		var half: float = enemy_size
		_body.offset_left = -half
		_body.offset_top = -half
		_body.offset_right = half
		_body.offset_bottom = half
