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
var _wave_director: Node = null
var _run_ended: bool = false

func _ready() -> void:
	RunState.reset()
	EventBus.run_started.emit()
	$HUD/EndRunButton.pressed.connect(_on_end_run_pressed)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.heat_changed.connect(_on_heat_changed)
	EventBus.shield_changed.connect(_on_shield_changed)
	_spawn_tower()
	_setup_wave_director()
	_update_hud()

func _process(delta: float) -> void:
	if _run_ended:
		return
	RunState.run_time += delta
	if _wave_director:
		_wave_director.process(delta)
	_update_hud()

func _spawn_tower() -> void:
	var tower_scene: PackedScene = preload("res://scenes/Tower.tscn")
	_tower = tower_scene.instantiate()
	add_child(_tower)
	_tower.global_position = TOWER_POSITION
	_tower.died.connect(_on_tower_died)

func _setup_wave_director() -> void:
	var wd_script: GDScript = load("res://scripts/combat/WaveDirector.gd")
	_wave_director = Node.new()
	_wave_director.set_script(wd_script)
	add_child(_wave_director)
	_wave_director.start(TOWER_POSITION)

func _on_tower_died() -> void:
	_end_run()

func _on_end_run_pressed() -> void:
	_end_run()

func _on_boss_spawned(boss_id: String) -> void:
	$HUD/BossBar.visible = true

func _on_boss_defeated(boss_id: String, reward: int) -> void:
	$HUD/BossBar.visible = false

func _on_heat_changed(current: float, max_heat: float) -> void:
	var bar: ProgressBar = $HUD/HeatBar
	bar.value = current
	bar.max_value = max_heat

func _on_shield_changed(current: float, max_shield: float) -> void:
	var bar: ProgressBar = $HUD/ShieldBar
	bar.value = current
	bar.max_value = max_shield

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

func _update_hud() -> void:
	var hud_panel: HBoxContainer = $HUD/HUDPanel
	hud_panel.get_node("HPLabel").text = "HP: %d" % RunState.tower_hp
	hud_panel.get_node("WaveLabel").text = "Wave: %d" % RunState.wave_number
	hud_panel.get_node("KillsLabel").text = "Kills: %d" % RunState.kills
	hud_panel.get_node("SalvageLabel").text = "Salvage: %d" % RunState.salvage
	hud_panel.get_node("TimerLabel").text = _format_time(RunState.run_time)
	if _tower and is_instance_valid(_tower) and _tower.heat_system:
		var bar: ProgressBar = $HUD/HeatBar
		bar.value = _tower.heat_system.heat
		bar.max_value = _tower.heat_system.max_heat
	if _tower and is_instance_valid(_tower) and _tower.shield_system:
		var bar: ProgressBar = $HUD/ShieldBar
		bar.value = _tower.shield_system.shield
		bar.max_value = _tower.shield_system.max_shield
	_update_boss_bar()

func _update_boss_bar() -> void:
	var boss_bar: ProgressBar = $HUD/BossBar
	var bosses: Array[Node] = get_tree().get_nodes_in_group("bosses")
	bosses = bosses.filter(func(b): return is_instance_valid(b))
	if bosses.size() > 0:
		var boss: Node2D = bosses[0]
		if boss.has_method("get_enemy_id"):
			boss_bar.visible = true
			boss_bar.max_value = boss.max_hp
			boss_bar.value = boss.hp
	else:
		boss_bar.visible = false

func _format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]
