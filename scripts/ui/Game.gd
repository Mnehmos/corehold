# Corehold
# File: scripts/ui/Game.gd
# Purpose: Game scene controller managing the active run
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
## Game scene controller. Manages the active run, combat loop, and wave progression.

const TOWER_POSITION: Vector2 = Vector2(640, 360)

var _tower: Node2D = null
var _wave_number: int = 0
var _enemies_alive: int = 0
var _wave_spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _wave_rest_timer: float = 0.0
var _is_spawning: bool = false
var _is_wave_rest: bool = false
var _run_ended: bool = false

func _ready() -> void:
	RunState.reset()
	EventBus.run_started.emit()
	$HUD/EndRunButton.pressed.connect(_on_end_run_pressed)
	_spawn_tower()
	_start_next_wave()
	_update_hud()

func _process(delta: float) -> void:
	if _run_ended:
		return
	RunState.run_time += delta
	_process_spawning(delta)
	if _is_wave_rest:
		_wave_rest_timer -= delta
		if _wave_rest_timer <= 0.0:
			_is_wave_rest = false
			_start_next_wave()
	if not _is_spawning and _enemies_alive <= 0 and not _is_wave_rest and _wave_number > 0:
		_is_wave_rest = true
		_wave_rest_timer = Constants.WAVE_REST_TIME
	_update_hud()

func _spawn_tower() -> void:
	var tower_scene: PackedScene = preload("res://scenes/Tower.tscn")
	_tower = tower_scene.instantiate()
	add_child(_tower)
	_tower.global_position = TOWER_POSITION
	_tower.died.connect(_on_tower_died)

func _on_tower_died() -> void:
	_end_run()

func _on_end_run_pressed() -> void:
	_end_run()

func _end_run() -> void:
	if _run_ended:
		return
	_run_ended = true
	EventBus.run_ended.emit(
		RunState.wave_number,
		RunState.kills,
		RunState.salvage,
		RunState.run_time
	)
	GameState.record_run(
		RunState.wave_number,
		RunState.kills,
		RunState.salvage,
		RunState.run_time
	)
	get_tree().change_scene_to_file("res://scenes/RunSummary.tscn")

func _start_next_wave() -> void:
	_wave_number += 1
	RunState.wave_number = _wave_number
	EventBus.wave_started.emit(_wave_number)
	_build_spawn_queue()
	_is_spawning = true
	_spawn_timer = 0.0

func _build_spawn_queue() -> void:
	_wave_spawn_queue.clear()
	var waves_data: Array = GameState.waves_data.get("waves", [])
	var wave_def: Dictionary = _find_wave_definition(waves_data, _wave_number)
	var groups: Array = wave_def.get("groups", [])
	var scaling: Dictionary = GameState.waves_data.get("scaling", {})
	var hp_mult: float = 1.0 + scaling.get("hp_multiplier_per_wave", 0.0) * (_wave_number - 1)
	var count_mult: float = 1.0 + scaling.get("count_multiplier_per_wave", 0.0) * (_wave_number - 1)
	for group in groups:
		var enemy_id: String = group.get("enemy", "swarmer")
		var count: int = int(group.get("count", 1) * count_mult)
		var delay: float = group.get("delay", 0.5)
		var enemy_data: Dictionary = GameState.get_enemy_by_id(enemy_id)
		if enemy_data.is_empty():
			continue
		if hp_mult > 1.0:
			enemy_data["hp"] = int(enemy_data.get("hp", 15) * hp_mult)
		for i in count:
			_wave_spawn_queue.append({"data": enemy_data.duplicate(), "delay": delay})

func _find_wave_definition(waves_data: Array, wave: int) -> Dictionary:
	var best: Dictionary = {}
	for w in waves_data:
		if w.get("wave", 0) <= wave:
			best = w
		else:
			break
	if best.is_empty() and waves_data.size() > 0:
		best = waves_data[0]
	return best

func _process_spawning(delta: float) -> void:
	if not _is_spawning or _wave_spawn_queue.is_empty():
		if _is_spawning and _wave_spawn_queue.is_empty():
			_is_spawning = false
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var entry: Dictionary = _wave_spawn_queue.pop_front()
		_spawn_enemy(entry["data"])
		_spawn_timer = entry.get("delay", 0.5)

func _spawn_enemy(data: Dictionary) -> void:
	var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
	var enemy: Node2D = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = _get_spawn_position()
	enemy.setup(data, TOWER_POSITION)
	enemy.died.connect(_on_enemy_died)
	_enemies_alive += 1
	EventBus.enemy_spawned.emit(data.get("id", "unknown"))

func _on_enemy_died(_enemy: Node2D) -> void:
	_enemies_alive -= 1

func _get_spawn_position() -> Vector2:
	var side: int = randi() % 4
	var margin: float = 40.0
	match side:
		0: return Vector2(randf() * 1280, -margin)
		1: return Vector2(randf() * 1280, 720 + margin)
		2: return Vector2(-margin, randf() * 720)
		3: return Vector2(1280 + margin, randf() * 720)
		_: return Vector2(-margin, 360)

func _update_hud() -> void:
	var hud_panel: HBoxContainer = $HUD/HUDPanel
	hud_panel.get_node("HPLabel").text = "HP: %d" % RunState.tower_hp
	hud_panel.get_node("WaveLabel").text = "Wave: %d" % RunState.wave_number
	hud_panel.get_node("KillsLabel").text = "Kills: %d" % RunState.kills
	hud_panel.get_node("SalvageLabel").text = "Salvage: %d" % RunState.salvage
	hud_panel.get_node("TimerLabel").text = _format_time(RunState.run_time)

func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]
