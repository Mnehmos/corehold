# Corehold
# File: scripts/combat/WaveDirector.gd
# Purpose: Wave director managing wave progression, spawning, and difficulty scaling
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
## Wave director. Manages wave progression, spawning, and difficulty scaling.

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal boss_wave_started(woss_id: String)

var wave_number: int = 0
var enemies_alive: int = 0
var _spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _is_spawning: bool = false
var _is_wave_rest: bool = false
var _wave_rest_timer: float = 0.0
var _waves_data: Array = []
var _scaling: Dictionary = {}
var _tower_position: Vector2 = Vector2.ZERO

func start(tower_pos: Vector2) -> void:
	_tower_position = tower_pos
	_waves_data = GameState.waves_data.get("waves", [])
	_scaling = GameState.waves_data.get("scaling", {})
	begin_next_wave()

func begin_next_wave() -> void:
	wave_number += 1
	RunState.wave_number = wave_number
	wave_started.emit(wave_number)
	EventBus.wave_started.emit(wave_number)
	_build_spawn_queue()
	_is_spawning = true
	_spawn_timer = 0.0
	var is_boss: bool = wave_number % Constants.BOSS_INTERVAL == 0
	if is_boss:
		boss_wave_started.emit("boss_core")

func process(delta: float) -> void:
	_process_spawning(delta)
	if _is_wave_rest:
		_wave_rest_timer -= delta
		if _wave_rest_timer <= 0.0:
			_is_wave_rest = false
			begin_next_wave()
	if not _is_spawning and enemies_alive <= 0 and not _is_wave_rest and wave_number > 0:
		wave_completed.emit(wave_number)
		EventBus.wave_completed.emit(wave_number)
		_grant_wave_bonus()
		_is_wave_rest = true
		_wave_rest_timer = Constants.WAVE_REST_TIME

func _build_spawn_queue() -> void:
	_spawn_queue.clear()
	var wave_def: Dictionary = _find_wave_definition(wave_number)
	var groups: Array = wave_def.get("groups", [])
	var is_boss_wave: bool = wave_number % Constants.BOSS_INTERVAL == 0
	if is_boss_wave:
		_build_boss_wave()
		return
	for group in groups:
		var enemy_id: String = group.get("enemy", "swarmer")
		var count: int = int(group.get("count", 1) * _get_count_multiplier())
		var delay: float = group.get("delay", 0.5)
		var enemy_data: Dictionary = GameState.get_enemy_by_id(enemy_id)
		if enemy_data.is_empty():
			continue
		var scaled_data: Dictionary = _apply_scaling(enemy_data.duplicate())
		for i in count:
			_spawn_queue.append({"data": scaled_data.duplicate(), "delay": delay})

func _build_boss_wave() -> void:
	var boss_data: Dictionary = GameState.get_enemy_by_id("boss_core")
	if boss_data.is_empty():
		return
	var scaled_boss: Dictionary = _apply_scaling(boss_data.duplicate())
	_spawn_queue.append({"data": scaled_boss, "delay": 0.0})
	var escort_count: int = maxi(3, wave_number / 5)
	var swarmer_data: Dictionary = GameState.get_enemy_by_id("swarmer")
	if not swarmer_data.is_empty():
		var scaled_swarmer: Dictionary = _apply_scaling(swarmer_data.duplicate())
		for i in escort_count:
			_spawn_queue.append({"data": scaled_swarmer.duplicate(), "delay": 0.8})

func _apply_scaling(data: Dictionary) -> Dictionary:
	var hp_mult: float = 1.0 + _scaling.get("hp_multiplier_per_wave", 0.0) * (wave_number - 1)
	var spd_mult: float = 1.0 + _scaling.get("speed_multiplier_per_wave", 0.0) * (wave_number - 1)
	data["hp"] = int(data.get("hp", 15) * hp_mult)
	if data.has("shield"):
		data["shield"] = int(data["shield"] * hp_mult)
	data["speed"] = data.get("speed", 100.0) * spd_mult
	return data

func _get_count_multiplier() -> float:
	return 1.0 + _scaling.get("count_multiplier_per_wave", 0.0) * (wave_number - 1)

func _find_wave_definition(wave: int) -> Dictionary:
	var best: Dictionary = {}
	for w in _waves_data:
		if w.get("wave", 0) <= wave:
			best = w
		else:
			break
	if best.is_empty() and _waves_data.size() > 0:
		best = _waves_data[0]
	return best

func _process_spawning(delta: float) -> void:
	if not _is_spawning or _spawn_queue.is_empty():
		if _is_spawning and _spawn_queue.is_empty():
			_is_spawning = false
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var entry: Dictionary = _spawn_queue.pop_front()
		_spawn_enemy(entry["data"])
		_spawn_timer = entry.get("delay", 0.5)

func _spawn_enemy(data: Dictionary) -> void:
	var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
	var enemy: Node2D = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _get_spawn_position()
	enemy.setup(data, _tower_position)
	enemy.died.connect(_on_enemy_died)
	if data.get("is_boss", false):
		EventBus.boss_spawned.emit(data.get("id", "boss_core"))
	enemies_alive += 1
	EventBus.enemy_spawned.emit(data.get("id", "unknown"))

func _on_enemy_died(enemy: Node2D) -> void:
	enemies_alive -= 1
	if enemy.has_method("get_enemy_id"):
		var eid: String = enemy.get_enemy_id()
		if eid == "boss_core":
			var reward: int = Constants.BOSS_KILL_BONUS
			RunState.salvage += reward
			EventBus.boss_defeated.emit(eid, reward)

func _get_spawn_position() -> Vector2:
	var side: int = randi() % 4
	var margin: float = 40.0
	match side:
		0: return Vector2(randf() * Constants.ARENA_WIDTH, -margin)
		1: return Vector2(randf() * Constants.ARENA_WIDTH, Constants.ARENA_HEIGHT + margin)
		2: return Vector2(-margin, randf() * Constants.ARENA_HEIGHT)
		3: return Vector2(Constants.ARENA_WIDTH + margin, randf() * Constants.ARENA_HEIGHT)
		_: return Vector2(-margin, 360)

func _grant_wave_bonus() -> void:
	RunState.salvage += Constants.WAVE_COMPLETION_BONUS

func is_resting() -> bool:
	return _is_wave_rest

func get_wave_number() -> int:
	return wave_number
