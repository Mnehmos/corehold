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
## Supports archetypes: swarmer, runner, brute, shielded, bomber, splitter, jammer, boss.

signal died(enemy: Node2D)

var enemy_id: String = ""
var enemy_name: String = ""
var hp: int = 15
var max_hp: int = 15
var speed: float = 120.0
var damage: int = 5
var salvage_reward: int = 2
var enemy_color: Color = Color.GREEN
var enemy_size: float = 8.0
var is_boss: bool = false
var shield_hp: int = 0
var max_shield_hp: int = 0
var shield_regen_rate: float = 2.0
var is_bomber: bool = false
var _tower_position: Vector2 = Vector2.ZERO
var _attack_cooldown: float = 0.0
var _attack_interval: float = 1.0
var _shield_regen_timer: float = 0.0
var _shield_regen_delay: float = 3.0
var _time_since_last_hit: float = 0.0

@onready var _body: ColorRect = $EnemyBody
@onready var _hitbox: Area2D = $Hitbox

func _ready() -> void:
	add_to_group("enemies")
	_update_visual()

func setup(data: Dictionary, tower_pos: Vector2) -> void:
	enemy_id = data.get("id", "unknown")
	enemy_name = data.get("name", "Unknown")
	hp = data.get("hp", 15)
	max_hp = hp
	speed = data.get("speed", 120.0)
	damage = data.get("damage", 5)
	salvage_reward = data.get("salvage_reward", 2)
	enemy_color = Color.from_string(data.get("color", "#55ff55"), Color.GREEN)
	enemy_size = data.get("size", 8.0)
	is_boss = data.get("is_boss", false)
	shield_hp = int(data.get("shield", 0))
	max_shield_hp = shield_hp
	is_bomber = enemy_id == "bomber"
	_tower_position = tower_pos
	if is_boss:
		add_to_group("bosses")
	_update_visual()

func get_enemy_id() -> String:
	return enemy_id

func _process(delta: float) -> void:
	if _tower_position == Vector2.ZERO:
		return
	_process_shield_regen(delta)
	var direction: Vector2 = global_position.direction_to(_tower_position)
	var distance: float = global_position.distance_to(_tower_position)
	if distance > 24.0:
		global_position += direction * speed * delta
	else:
		_attack_cooldown -= delta
		if _attack_cooldown <= 0.0:
			_attack_tower()
			if is_bomber:
				_die()
				return
			_attack_cooldown = _attack_interval

func take_damage(amount: int) -> void:
	_time_since_last_hit = 0.0
	if shield_hp > 0:
		var absorbed: int = mini(amount, shield_hp)
		shield_hp -= absorbed
		amount -= absorbed
	hp -= amount
	if hp <= 0:
		_die()

func _process_shield_regen(delta: float) -> void:
	if max_shield_hp <= 0:
		return
	_time_since_last_hit += delta
	if _time_since_last_hit >= _shield_regen_delay:
		shield_hp = mini(max_shield_hp, shield_hp + int(shield_regen_rate * delta))

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
